-- ============================================================
-- Migration: RPC functions untuk operasi student workspace
-- ============================================================

-- FUNGSI 1: Lookup project by join_code (bypass RLS)
-- Diperlukan karena student_project_select RLS mengharuskan
-- mahasiswa sudah jadi member sebelum bisa SELECT project.
-- Dengan SECURITY DEFINER, fungsi ini berjalan sebagai pemilik
-- (postgres), sehingga bisa membaca projects tanpa terkena RLS.
-- ============================================================
CREATE OR REPLACE FUNCTION get_project_by_join_code(p_join_code TEXT)
RETURNS TABLE (
  id             uuid,
  lecturer_id    uuid,
  title          varchar,
  description    text,
  join_code      varchar,
  final_submission_info text,
  created_at     timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
    SELECT
      p.id,
      p.lecturer_id,
      p.title,
      p.description,
      p.join_code,
      p.final_submission_info,
      p.created_at
    FROM projects p
    WHERE p.join_code = p_join_code
    LIMIT 1;
END;
$$;

-- Revoke akses langsung; hanya bisa dipanggil via fungsi ini
REVOKE ALL ON FUNCTION get_project_by_join_code(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_project_by_join_code(TEXT) TO authenticated;


-- FUNGSI 2: Buat workspace sekaligus set ketua (atomic transaction)
-- Mengatasi masalah project_id NOT NULL: workspace dibuat langsung
-- dengan project_id yang sudah valid dari join_code.
-- ============================================================
CREATE OR REPLACE FUNCTION create_workspace_and_join_project(
  p_join_code        TEXT,
  p_team_name        TEXT,
  p_topic_name       TEXT DEFAULT NULL,
  p_topic_description TEXT DEFAULT NULL,
  p_client_created_at timestamptz DEFAULT now()
)
RETURNS TABLE (
  workspace_id uuid,
  project_id   uuid,
  project_title varchar
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_project       projects%ROWTYPE;
  v_workspace_id  uuid := gen_random_uuid();
  v_member_id     uuid := gen_random_uuid();
BEGIN
  -- 1. Cari project berdasarkan join_code
  SELECT * INTO v_project FROM projects WHERE projects.join_code = p_join_code LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PROJECT_NOT_FOUND: Proyek dengan join code "%" tidak ditemukan.', p_join_code;
  END IF;

  -- 2. Insert workspace dengan project_id yang sudah valid
  INSERT INTO workspaces (id, project_id, team_name, topic_name, topic_description, progression_mode, is_completed, client_created_at)
  VALUES (
    v_workspace_id,
    v_project.id,
    p_team_name,
    p_topic_name,
    p_topic_description,
    'strict',
    false,
    p_client_created_at
  );

  -- 3. Insert creator sebagai ketua workspace (SECURITY DEFINER bypass RLS member_insert)
  INSERT INTO workspace_members (id, workspace_id, student_id, is_leader)
  VALUES (v_member_id, v_workspace_id, auth.uid(), true);

  -- 4. Kembalikan hasilnya
  RETURN QUERY SELECT v_workspace_id, v_project.id, v_project.title;
END;
$$;

REVOKE ALL ON FUNCTION create_workspace_and_join_project(TEXT, TEXT, TEXT, TEXT, timestamptz) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION create_workspace_and_join_project(TEXT, TEXT, TEXT, TEXT, timestamptz) TO authenticated;


-- FUNGSI 3: Link workspace yang sudah ada ke project baru via join_code
-- Untuk ketua yang sudah punya workspace (dibuat sebelum join project).
-- ============================================================
CREATE OR REPLACE FUNCTION link_workspace_to_project_by_code(
  p_workspace_id uuid,
  p_join_code    TEXT
)
RETURNS TABLE (
  project_id    uuid,
  project_title varchar
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_project projects%ROWTYPE;
BEGIN
  -- 1. Cari project
  SELECT * INTO v_project FROM projects WHERE projects.join_code = p_join_code LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'PROJECT_NOT_FOUND: Proyek dengan join code "%" tidak ditemukan.', p_join_code;
  END IF;

  -- 2. Pastikan caller adalah ketua workspace
  IF NOT EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_id = p_workspace_id
      AND student_id = auth.uid()
      AND is_leader = true
  ) THEN
    RAISE EXCEPTION 'FORBIDDEN: Hanya ketua workspace yang bisa menghubungkan ke project.';
  END IF;

  -- 3. Update project_id di workspace
  UPDATE workspaces SET project_id = v_project.id WHERE id = p_workspace_id;

  RETURN QUERY SELECT v_project.id, v_project.title;
END;
$$;

REVOKE ALL ON FUNCTION link_workspace_to_project_by_code(uuid, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION link_workspace_to_project_by_code(uuid, TEXT) TO authenticated;
