-- Fix: Perbesar kolom evidence_file_url dari varchar(255) ke text
-- Signed URL dari Supabase Storage bisa sangat panjang (>255 karakter)
ALTER TABLE "submissions"
  ALTER COLUMN "evidence_file_url" TYPE text;
