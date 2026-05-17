ALTER TABLE "submissions" ALTER COLUMN "phase_id" DROP NOT NULL;
ALTER TABLE "submissions" ALTER COLUMN "evidence_file_url" TYPE text;
