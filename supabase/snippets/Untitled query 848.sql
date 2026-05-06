-- 1. Tambah kolom progress ke task_allocations
ALTER TABLE public.task_allocations
  ADD COLUMN IF NOT EXISTS progress smallint NOT NULL DEFAULT 0
  CONSTRAINT progress_range CHECK (progress >= 0 AND progress <= 100);

-- 2. Tambah kolom task_id ke submissions (nullable, FK ke task_allocations)
ALTER TABLE public.submissions
  ADD COLUMN IF NOT EXISTS task_id uuid REFERENCES public.task_allocations(id) ON DELETE SET NULL;
