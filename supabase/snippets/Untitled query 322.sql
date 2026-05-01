DROP POLICY IF EXISTS "student_project_select" ON "public"."projects";

CREATE POLICY "student_project_select" 
ON "public"."projects"
FOR SELECT 
TO authenticated 
USING ( true ); 
-- Catatan: Menggunakan 'true' di sini berarti semua mahasiswa bisa melihat 
-- daftar proyek, tapi mereka tidak bisa melihat 'workspace' milik orang lain.