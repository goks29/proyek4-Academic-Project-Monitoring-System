-- Fix: Jadikan kolom phase_id di tabel submissions NULLABLE
-- Kolom phase_id sebenarnya redundan karena phase bisa ditelusuri dari task_id,
-- namun karena sudah ada di DB live, kita jadikan nullable agar lebih fleksibel.
ALTER TABLE "submissions"
  ALTER COLUMN "phase_id" DROP NOT NULL;

-- Fix: Perbesar kolom evidence_file_url dari varchar(255) ke text
-- Signed URL dari Supabase Storage bisa sangat panjang (>255 karakter)
ALTER TABLE "submissions"
  ALTER COLUMN "evidence_file_url" TYPE text;
