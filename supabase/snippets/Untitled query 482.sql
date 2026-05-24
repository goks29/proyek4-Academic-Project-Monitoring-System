-- Hapus policy lama
DROP POLICY IF EXISTS "member_select" ON workspace_members;

-- Buat policy baru yang tidak recursive
CREATE POLICY "member_select"
ON public.workspace_members
FOR SELECT
TO authenticated
USING (
  -- Mahasiswa hanya bisa lihat row miliknya sendiri
  student_id = auth.uid()
  OR
  -- Dosen bisa lihat semua member di workspace project miliknya
  EXISTS (
    SELECT 1
    FROM workspaces w
    JOIN projects p ON p.join_code = w.join_code
    WHERE w.id = workspace_members.workspace_id
      AND p.lecturer_id = auth.uid()
  )
);