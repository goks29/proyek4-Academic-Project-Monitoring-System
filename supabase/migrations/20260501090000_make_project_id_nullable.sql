-- ============================================================
-- Migration: Update RLS policies untuk mendukung workspace
-- tanpa project (join_code IS NULL).
-- Alasan: Mahasiswa bisa membuat workspace terlebih dahulu tanpa
-- harus langsung join ke project dosen. join_code bisa diisi
-- kemudian via linkWorkspaceToProject ketika ketua sudah punya
-- join_code dari dosen.
-- ============================================================

-- Update RLS workspace_update: tambahkan kondisi untuk workspace
-- yang belum terhubung ke project (join_code IS NULL) agar
-- ketua tetap bisa update (misal: mengisi topik, mengubah nama tim)
DROP POLICY IF EXISTS "workspace_update" ON "workspaces";
CREATE POLICY "workspace_update" ON "workspaces" FOR UPDATE TO authenticated
USING (
  -- Ketua workspace bisa update kapanpun (termasuk saat belum ada project)
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_id = workspaces.id
      AND student_id = auth.uid()
      AND is_leader = true
  )
  OR
  -- Dosen pemilik project bisa update jika workspace sudah terhubung
  (
    workspaces.join_code IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM projects
      WHERE join_code = workspaces.join_code
        AND lecturer_id = auth.uid()
    )
  )
);

-- Update RLS workspace_select: tambahkan kondisi untuk workspace
-- yang belum terhubung ke project agar bisa dibaca anggotanya
DROP POLICY IF EXISTS "workspace_select" ON "workspaces";
CREATE POLICY "workspace_select" ON "workspaces" FOR SELECT TO authenticated
USING (
  -- Anggota tim bisa lihat workspace-nya (termasuk yang belum punya project)
  EXISTS (
    SELECT 1 FROM workspace_members
    WHERE workspace_id = workspaces.id
      AND student_id = auth.uid()
  )
  OR
  -- Dosen bisa lihat workspace yang terhubung ke projectnya
  (
    workspaces.join_code IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM projects
      WHERE join_code = workspaces.join_code
        AND lecturer_id = auth.uid()
    )
  )
);
