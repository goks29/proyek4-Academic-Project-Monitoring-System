-- =============================================================================
-- Migration: Add Offline Submission Support
-- =============================================================================

-- 1. Tambah kolom deadline di progress_phases
-- Deadline berlaku untuk semua task dalam satu fase, di-set oleh ketua.
ALTER TABLE "progress_phases" ADD COLUMN "deadline" TIMESTAMPTZ;

-- 2. Tambah kolom offline support di submissions
ALTER TABLE "submissions" ADD COLUMN "file_hash" VARCHAR(64);
ALTER TABLE "submissions" ADD COLUMN "estimated_submit_at" TIMESTAMPTZ;
ALTER TABLE "submissions" ADD COLUMN "sync_nonce" UUID;
ALTER TABLE "submissions" ADD COLUMN "sync_status" VARCHAR(20) DEFAULT 'direct';
-- sync_status values: 'direct' (online submit), 'pending_sync', 'synced', 'rejected'

-- 3. Tabel anti-replay nonce
CREATE TABLE "submission_nonces" (
  "nonce" UUID PRIMARY KEY,
  "user_id" UUID NOT NULL REFERENCES "users"("id"),
  "used_at" TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE "submission_nonces" ENABLE ROW LEVEL SECURITY;

-- Hanya server (via RPC) yang bisa insert nonce, tapi user bisa lihat nonce mereka
CREATE POLICY "nonce_select" ON "submission_nonces" FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "nonce_insert" ON "submission_nonces" FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

-- 4. Secret key untuk HMAC signing (simpan di vault / config table)
-- Untuk produksi, ini harus di Supabase Vault. Untuk sekarang pakai config table.
CREATE TABLE IF NOT EXISTS "app_config" (
  "key" VARCHAR(100) PRIMARY KEY,
  "value" TEXT NOT NULL
);

-- Insert HMAC secret key (ganti dengan key yang lebih kuat di produksi!)
INSERT INTO "app_config" ("key", "value") 
VALUES ('hmac_secret', 'offline-submission-secret-key-change-in-production-2026')
ON CONFLICT ("key") DO NOTHING;

-- Hanya bisa diakses via RPC, bukan langsung
ALTER TABLE "app_config" ENABLE ROW LEVEL SECURITY;
-- Tidak ada policy = tidak bisa diakses langsung oleh client

-- =============================================================================
-- 5. RPC: issue_session_token
-- Generate signed session token untuk offline submission
-- =============================================================================
CREATE OR REPLACE FUNCTION issue_session_token(
  p_device_id TEXT,
  p_monotonic_at_issue BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Berjalan dengan hak superuser agar bisa baca app_config
AS $$
DECLARE
  v_user_id UUID;
  v_server_time TIMESTAMPTZ;
  v_expires_at TIMESTAMPTZ;
  v_hmac_secret TEXT;
  v_payload TEXT;
  v_signature TEXT;
BEGIN
  -- Ambil user ID dari session
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Ambil server time
  v_server_time := now();
  
  -- Hitung expiry: ambil deadline terjauh dari task user + 2 jam
  -- Jika tidak ada deadline, default 24 jam dari sekarang
  SELECT COALESCE(
    MAX(pp.deadline) + INTERVAL '2 hours',
    v_server_time + INTERVAL '24 hours'
  ) INTO v_expires_at
  FROM task_allocations ta
  JOIN progress_phases pp ON pp.id = ta.phase_id
  WHERE ta.student_id = v_user_id
    AND pp.deadline IS NOT NULL
    AND pp.deadline > v_server_time;

  -- Ambil HMAC secret
  SELECT value INTO v_hmac_secret FROM app_config WHERE key = 'hmac_secret';
  IF v_hmac_secret IS NULL THEN
    RAISE EXCEPTION 'HMAC secret not configured';
  END IF;

  -- Buat payload untuk signing
  v_payload := v_user_id::TEXT || '|' || p_device_id || '|' || 
               extract(epoch from v_server_time)::TEXT || '|' || 
               p_monotonic_at_issue::TEXT || '|' || 
               extract(epoch from v_expires_at)::TEXT;

  -- Generate HMAC-SHA256 signature
  v_signature := encode(
    extensions.hmac(v_payload::bytea, v_hmac_secret::bytea, 'sha256'),
    'hex'
  );

  -- Return token sebagai JSON
  RETURN jsonb_build_object(
    'user_id', v_user_id,
    'device_id', p_device_id,
    'server_time', v_server_time,
    'monotonic_at_issue', p_monotonic_at_issue,
    'expires_at', v_expires_at,
    'signature', v_signature
  );
END;
$$;

-- =============================================================================
-- 6. RPC: verify_offline_submission
-- Verifikasi submission offline dan insert ke tabel submissions
-- =============================================================================
CREATE OR REPLACE FUNCTION verify_offline_submission(
  p_task_id UUID,
  p_student_id UUID,
  p_evidence_file_url TEXT,
  p_student_notes TEXT,
  p_file_hash VARCHAR(64),
  p_estimated_submit_at TIMESTAMPTZ,
  p_sync_nonce UUID,
  -- Token fields
  p_token_user_id UUID,
  p_token_device_id TEXT,
  p_token_server_time TIMESTAMPTZ,
  p_token_monotonic_at_issue BIGINT,
  p_token_expires_at TIMESTAMPTZ,
  p_token_signature TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_hmac_secret TEXT;
  v_payload TEXT;
  v_expected_sig TEXT;
  v_submission_id UUID;
  v_phase_deadline TIMESTAMPTZ;
  v_sync_status TEXT;
BEGIN
  -- 1. Verifikasi user yang memanggil = user di token = student_id
  IF auth.uid() != p_token_user_id OR auth.uid() != p_student_id THEN
    RETURN jsonb_build_object('status', 'rejected', 'reason', 'User mismatch');
  END IF;

  -- 2. Verifikasi HMAC signature
  SELECT value INTO v_hmac_secret FROM app_config WHERE key = 'hmac_secret';
  
  v_payload := p_token_user_id::TEXT || '|' || p_token_device_id || '|' || 
               extract(epoch from p_token_server_time)::TEXT || '|' || 
               p_token_monotonic_at_issue::TEXT || '|' || 
               extract(epoch from p_token_expires_at)::TEXT;

  v_expected_sig := encode(
    extensions.hmac(v_payload::bytea, v_hmac_secret::bytea, 'sha256'),
    'hex'
  );

  IF v_expected_sig != p_token_signature THEN
    RETURN jsonb_build_object('status', 'rejected', 'reason', 'Invalid token signature');
  END IF;

  -- 3. Cek token belum expired
  IF p_token_expires_at < now() THEN
    RETURN jsonb_build_object('status', 'rejected', 'reason', 'Token expired');
  END IF;

  -- 4. Cek nonce belum dipakai (anti-replay)
  IF EXISTS (SELECT 1 FROM submission_nonces WHERE nonce = p_sync_nonce) THEN
    RETURN jsonb_build_object('status', 'rejected', 'reason', 'Nonce already used (replay attack)');
  END IF;

  -- 5. Simpan nonce
  INSERT INTO submission_nonces (nonce, user_id) VALUES (p_sync_nonce, p_student_id);

  -- 6. Cek estimated_submit_at masih sebelum deadline + 2 jam
  SELECT pp.deadline INTO v_phase_deadline
  FROM task_allocations ta
  JOIN progress_phases pp ON pp.id = ta.phase_id
  WHERE ta.id = p_task_id;

  IF v_phase_deadline IS NOT NULL AND p_estimated_submit_at > (v_phase_deadline + INTERVAL '2 hours') THEN
    v_sync_status := 'rejected';
  ELSE
    v_sync_status := 'synced';
  END IF;

  -- 7. Insert submission
  INSERT INTO submissions (
    task_id, student_id, submitted_at, evidence_file_url, student_notes,
    status, file_hash, estimated_submit_at, sync_nonce, sync_status
  ) VALUES (
    p_task_id, p_student_id, p_estimated_submit_at, p_evidence_file_url, p_student_notes,
    'pending', p_file_hash, p_estimated_submit_at, p_sync_nonce, v_sync_status
  )
  RETURNING id INTO v_submission_id;

  RETURN jsonb_build_object(
    'status', v_sync_status,
    'submission_id', v_submission_id,
    'reason', CASE WHEN v_sync_status = 'rejected' THEN 'Submission past deadline' ELSE NULL END
  );
END;
$$;
