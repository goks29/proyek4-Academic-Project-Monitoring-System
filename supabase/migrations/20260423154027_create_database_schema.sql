-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Custom Types
CREATE TYPE "user_role" AS ENUM ('lecturer', 'student');
CREATE TYPE "approval_status" AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE "progression_mode" AS ENUM ('strict', 'flexible');
-- Aktifkan ekstensi pgcrypto untuk fungsi hashing password
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

-- 1. Table Users
CREATE TABLE "users" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "full_name" varchar(255) NOT NULL,
  "email" varchar(255) UNIQUE NOT NULL,
  "password" varchar(255) NOT NULL,
  "role" user_role NOT NULL,
  "created_at" timestamptz DEFAULT now()
);

-- 2. Table Projects
CREATE TABLE "projects" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "lecturer_id" uuid NOT NULL,
  "title" varchar(255) NOT NULL,
  "description" text,
  "join_code" varchar(10) UNIQUE NOT NULL,
  "final_submission_info" text, 
  "created_at" timestamptz DEFAULT now()
);

-- 3. Table Workspaces
CREATE TABLE "workspaces" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "project_id" uuid NOT NULL,
  "team_name" varchar(255) NOT NULL,
  "topic_name" varchar(255),
  "topic_description" text,
  "progression_mode" progression_mode DEFAULT 'strict',
  "is_completed" boolean DEFAULT false,
  "client_created_at" timestamptz NOT NULL,
  "server_received_at" timestamptz DEFAULT now()
);

-- 4. Table Workspace Members
CREATE TABLE "workspace_members" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "workspace_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "is_leader" boolean DEFAULT false,
  UNIQUE("workspace_id", "student_id")
);

-- 5. Table Progress Phases
CREATE TABLE "progress_phases" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "workspace_id" uuid NOT NULL,
  "phase_name" varchar(255) NOT NULL,
  "sort_order" integer NOT NULL,
  "status" approval_status DEFAULT 'pending',
  "lecturer_feedback" text,
  "require_evidence" boolean DEFAULT true,
  "is_locked" boolean DEFAULT true,
  "client_created_at" timestamptz NOT NULL,
  "server_received_at" timestamptz DEFAULT now()
);

-- 6. Table Task Allocations
CREATE TABLE "task_allocations" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "phase_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "task_description" text NOT NULL,
  "status" approval_status DEFAULT 'pending',
  "lecturer_feedback" text,
  "is_done" boolean DEFAULT false,
  "progress" integer DEFAULT 0,
  "client_created_at" timestamptz NOT NULL,
  "server_received_at" timestamptz DEFAULT now()
);

-- 7. Table Submissions
CREATE TABLE "submissions" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "phase_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "submitted_at" timestamptz NOT NULL,
  "evidence_file_url" varchar(255),
  "student_notes" text,
  "status" approval_status DEFAULT 'pending',
  "lecturer_feedback" text,
  "lecturer_id" uuid,
  "server_received_at" timestamptz DEFAULT now()
);

-- 8. Table Comments
CREATE TABLE "comments" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "submission_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "comment_text" text NOT NULL,
  "client_created_at" timestamptz NOT NULL,
  "server_received_at" timestamptz DEFAULT now()
);

-- Foreign Key Constraints
ALTER TABLE "projects" ADD FOREIGN KEY ("lecturer_id") REFERENCES "users" ("id");
ALTER TABLE "workspaces" ADD FOREIGN KEY ("project_id") REFERENCES "projects" ("id");
ALTER TABLE "workspace_members" ADD FOREIGN KEY ("workspace_id") REFERENCES "workspaces" ("id");
ALTER TABLE "workspace_members" ADD FOREIGN KEY ("student_id") REFERENCES "users" ("id");
ALTER TABLE "progress_phases" ADD FOREIGN KEY ("workspace_id") REFERENCES "workspaces" ("id");
ALTER TABLE "task_allocations" ADD FOREIGN KEY ("phase_id") REFERENCES "progress_phases" ("id");
ALTER TABLE "task_allocations" ADD FOREIGN KEY ("student_id") REFERENCES "users" ("id");
ALTER TABLE "submissions" ADD FOREIGN KEY ("phase_id") REFERENCES "progress_phases" ("id");
ALTER TABLE "submissions" ADD FOREIGN KEY ("student_id") REFERENCES "users" ("id");
ALTER TABLE "submissions" ADD FOREIGN KEY ("lecturer_id") REFERENCES "users" ("id");
ALTER TABLE "comments" ADD FOREIGN KEY ("submission_id") REFERENCES "submissions" ("id");
ALTER TABLE "comments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

-- Ensure only one leader per workspace
CREATE UNIQUE INDEX one_leader_per_workspace 
ON "workspace_members" ("workspace_id") 
WHERE ("is_leader" = true);

-- Link public users to Supabase Auth
ALTER TABLE "users" 
ADD CONSTRAINT fk_supabase_auth 
FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE "users" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "projects" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "workspaces" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "workspace_members" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "progress_phases" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "task_allocations" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "submissions" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "comments" ENABLE ROW LEVEL SECURITY;

-- Siapa pun yang login bisa melihat profil user lain
CREATE POLICY "user_select_policy" ON "users" FOR SELECT TO authenticated USING (true);

-- Hanya pemilik akun yang bisa edit data dirinya
CREATE POLICY "user_update_policy" ON "users" FOR UPDATE TO authenticated USING (id = auth.uid());

-- Dosen pemilik proyek punya akses penuh
CREATE POLICY "lecturer_project_all" ON "projects" FOR ALL TO authenticated 
USING (lecturer_id = auth.uid());

-- Mahasiswa bisa melihat proyek jika mereka tahu join_code (via app logic) 
-- atau sudah bergabung di salah satu workspace di proyek tersebut
CREATE POLICY "student_project_select" ON "projects" FOR SELECT TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM workspaces w
    JOIN workspace_members wm ON wm.workspace_id = w.id
    WHERE w.project_id = projects.id AND wm.student_id = auth.uid()
  )
);

-- Anggota tim & dosen proyek bisa melihat workspace
CREATE POLICY "workspace_select" ON "workspaces" FOR SELECT TO authenticated 
USING (
  EXISTS (SELECT 1 FROM workspace_members WHERE workspace_id = workspaces.id AND student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM projects WHERE id = workspaces.project_id AND lecturer_id = auth.uid())
);

-- Mahasiswa bisa membuat workspace (saat join project)
CREATE POLICY "workspace_insert" ON "workspaces" FOR INSERT TO authenticated WITH CHECK (true);

-- Hanya KETUA atau DOSEN yang bisa update data kelompok (seperti topik)
CREATE POLICY "workspace_update" ON "workspaces" FOR UPDATE TO authenticated 
USING (
  EXISTS (SELECT 1 FROM workspace_members WHERE workspace_id = workspaces.id AND student_id = auth.uid() AND is_leader = true)
  OR EXISTS (SELECT 1 FROM projects WHERE id = workspaces.project_id AND lecturer_id = auth.uid())
);

-- Anggota tim & dosen proyek bisa melihat daftar anggota
CREATE POLICY "member_select" ON "workspace_members" FOR SELECT TO authenticated 
USING (
  EXISTS (SELECT 1 FROM workspace_members internal WHERE internal.workspace_id = workspace_members.workspace_id AND internal.student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM workspaces w JOIN projects p ON p.id = w.project_id WHERE w.id = workspace_members.workspace_id AND p.lecturer_id = auth.uid())
);

-- Hanya mahasiswa yang membuat kelompok (ketua) yang bisa menambah anggota
CREATE POLICY "member_insert" ON "workspace_members" FOR INSERT TO authenticated WITH CHECK (true);

-- SELECT: Anggota & Dosen
CREATE POLICY "phase_select" ON "progress_phases" FOR SELECT TO authenticated 
USING (
  EXISTS (SELECT 1 FROM workspace_members WHERE workspace_id = progress_phases.workspace_id AND student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM workspaces w JOIN projects p ON p.id = w.project_id WHERE w.id = progress_phases.workspace_id AND p.lecturer_id = auth.uid())
);

-- INSERT: HANYA KETUA
CREATE POLICY "phase_insert" ON "progress_phases" FOR INSERT TO authenticated 
WITH CHECK (
  EXISTS (SELECT 1 FROM workspace_members WHERE workspace_id = progress_phases.workspace_id AND student_id = auth.uid() AND is_leader = true)
);

-- UPDATE: KETUA (isi) atau DOSEN (status/feedback)
CREATE POLICY "phase_update" ON "progress_phases" FOR UPDATE TO authenticated 
USING (
  EXISTS (SELECT 1 FROM workspace_members WHERE workspace_id = progress_phases.workspace_id AND student_id = auth.uid() AND is_leader = true)
  OR EXISTS (SELECT 1 FROM workspaces w JOIN projects p ON p.id = w.project_id WHERE w.id = progress_phases.workspace_id AND p.lecturer_id = auth.uid())
);

-- SELECT: Anggota & Dosen
CREATE POLICY "task_select" ON "task_allocations" FOR SELECT TO authenticated 
USING (
  EXISTS (SELECT 1 FROM progress_phases pp JOIN workspace_members wm ON wm.workspace_id = pp.workspace_id WHERE pp.id = task_allocations.phase_id AND wm.student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM progress_phases pp JOIN workspaces w ON w.id = pp.workspace_id JOIN projects p ON p.id = w.project_id WHERE pp.id = task_allocations.phase_id AND p.lecturer_id = auth.uid())
);

-- INSERT: HANYA KETUA
CREATE POLICY "task_insert" ON "task_allocations" FOR INSERT TO authenticated 
WITH CHECK (
  EXISTS (SELECT 1 FROM progress_phases pp JOIN workspace_members wm ON wm.workspace_id = pp.workspace_id WHERE pp.id = task_allocations.phase_id AND wm.student_id = auth.uid() AND is_leader = true)
);

-- UPDATE: KETUA (deskripsi), MHS (is_done), DOSEN (status)
CREATE POLICY "task_update" ON "task_allocations" FOR UPDATE TO authenticated 
USING (
  EXISTS (SELECT 1 FROM progress_phases pp JOIN workspace_members wm ON wm.workspace_id = pp.workspace_id WHERE pp.id = task_allocations.phase_id AND wm.student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM progress_phases pp JOIN workspaces w ON w.id = pp.workspace_id JOIN projects p ON p.id = w.project_id WHERE pp.id = task_allocations.phase_id AND p.lecturer_id = auth.uid())
);

-- Submissions: Anggota bisa insert, semua tim & dosen bisa lihat
CREATE POLICY "sub_select" ON "submissions" FOR SELECT TO authenticated 
USING (
  EXISTS (SELECT 1 FROM workspace_members wm JOIN progress_phases pp ON pp.workspace_id = wm.workspace_id WHERE pp.id = submissions.phase_id AND wm.student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM progress_phases pp JOIN workspaces w ON w.id = pp.workspace_id JOIN projects p ON p.id = w.project_id WHERE pp.id = submissions.phase_id AND p.lecturer_id = auth.uid())
);

CREATE POLICY "sub_insert" ON "submissions" FOR INSERT TO authenticated 
WITH CHECK (
  EXISTS (SELECT 1 FROM workspace_members wm JOIN progress_phases pp ON pp.workspace_id = wm.workspace_id WHERE pp.id = submissions.phase_id AND wm.student_id = auth.uid())
);

-- Comments: Terbuka untuk diskusi dalam tim dan dosen terkait
CREATE POLICY "comment_policy" ON "comments" FOR ALL TO authenticated 
USING (
  EXISTS (SELECT 1 FROM submissions s JOIN progress_phases pp ON pp.id = s.phase_id JOIN workspace_members wm ON wm.workspace_id = pp.workspace_id WHERE s.id = comments.submission_id AND wm.student_id = auth.uid())
  OR EXISTS (SELECT 1 FROM submissions s JOIN progress_phases pp ON pp.id = s.phase_id JOIN workspaces w ON w.id = pp.workspace_id JOIN projects p ON p.id = w.project_id WHERE s.id = comments.submission_id AND p.lecturer_id = auth.uid())
);