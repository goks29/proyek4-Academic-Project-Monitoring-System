-- Izinkan user yang sudah login untuk UPLOAD file ke bucket task-evidence
CREATE POLICY "Authenticated users can upload evidence"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'task-evidence');

-- Izinkan user yang sudah login untuk MEMBACA file di bucket task-evidence
CREATE POLICY "Authenticated users can read evidence"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'task-evidence');
