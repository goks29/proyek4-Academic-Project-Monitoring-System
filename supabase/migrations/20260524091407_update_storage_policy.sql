-- 1. Menambahkan bucket baru jika belum ada
INSERT INTO storage.buckets (id, name, public)
VALUES ('task-evidence', 'task-evidence', false)
ON CONFLICT (id) DO NOTHING;

-- 2. Menghapus policy lama yang salah (jika ada)
DROP POLICY IF EXISTS "Give users authenticated access to folder" ON storage.objects;

-- 3. Menambahkan policy baru untuk proses INSERT
CREATE POLICY "Allow authenticated uploads" ON storage.objects 
FOR INSERT TO public 
WITH CHECK (bucket_id = 'task-evidence' AND auth.role() = 'authenticated');

-- Mengizinkan pengguna yang sudah login untuk membaca/melihat file
CREATE POLICY "Allow authenticated read" ON storage.objects 
FOR SELECT TO public 
USING (bucket_id = 'task-evidence' AND auth.role() = 'authenticated');