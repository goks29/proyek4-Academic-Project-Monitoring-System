
--AUTH USERS (Internal Supabase)
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
  ('d05e0001-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'joko@dosen.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('d05e0002-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bowo@dosen.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330001-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'prubaya@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330002-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'bahlil@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330003-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'gibran@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330004-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ganjar@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330005-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mahfud@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330006-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'timothy@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330007-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'anies@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330008-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'cakimin@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330009-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'Dadan-mbg@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330010-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'zulhas@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330011-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'amrans@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330012-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'luhut@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330013-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'alditaher@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330014-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'pigai@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330015-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'tirta@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');

INSERT INTO "public"."users" ("id", "full_name", "email", "password", "role") VALUES
('d05e0001-0000-0000-0000-000000000000', 'Pak Joko', 'joko@dosen.ac.id', 'password123', 'lecturer'),
('d05e0002-0000-0000-0000-000000000000', 'Pak Bowo', 'bowo@dosen.ac.id', 'password123', 'lecturer'),
('33330001-0000-0000-0000-000000000000', 'Prubaya', 'prubaya@mhs.ac.id', 'password123', 'student'),
('33330002-0000-0000-0000-000000000000', 'Bahlil', 'bahlil@mhs.ac.id', 'password123', 'student'),
('33330003-0000-0000-0000-000000000000', 'Gibran', 'gibran@mhs.ac.id', 'password123', 'student'),
('33330004-0000-0000-0000-000000000000', 'Ganjar', 'ganjar@mhs.ac.id', 'password123', 'student'),
('33330005-0000-0000-0000-000000000000', 'Mahfud', 'mahfud@mhs.ac.id', 'password123', 'student'),
('33330006-0000-0000-0000-000000000000', 'Timothy', 'timothy@mhs.ac.id', 'password123', 'student'),
('33330007-0000-0000-0000-000000000000', 'Anies', 'anies@mhs.ac.id', 'password123', 'student'),
('33330008-0000-0000-0000-000000000000', 'Cak Imin', 'cakimin@mhs.ac.id', 'password123', 'student'),
('33330009-0000-0000-0000-000000000000', 'Dadan-MBG', 'Dadan-mbg@mhs.ac.id', 'password123', 'student'),
('33330010-0000-0000-0000-000000000000', 'Zulhas', 'zulhas@mhs.ac.id', 'password123', 'student'),
('33330011-0000-0000-0000-000000000000', 'Amran Sulaiman', 'amrans@mhs.ac.id', 'password123', 'student'),
('33330012-0000-0000-0000-000000000000', 'Luhut', 'luhut@mhs.ac.id', 'password123', 'student'),
('33330013-0000-0000-0000-000000000000', 'Aldi Taher', 'alditaher@mhs.ac.id', 'password123', 'student'),
('33330014-0000-0000-0000-000000000000', 'Pigai', 'pigai@mhs.ac.id', 'password123', 'student'),
('33330015-0000-0000-0000-000000000000', 'Tirta Pengpeng', 'tirta@mhs.ac.id', 'password123', 'student');

INSERT INTO "public"."projects" ("id", "lecturer_id", "title", "description", "join_code") VALUES
('a1000000-0000-0000-0000-000000000000', 'd05e0001-0000-0000-0000-000000000000', 'Pengembangan Aplikasi Web', 'Tugas Besar Semester 4 - Mode Strict', 'WEB-STRICT'),
('a2000000-0000-0000-0000-000000000000', 'd05e0002-0000-0000-0000-000000000000', 'Pengembangan Aplikasi Mobile', 'Tugas Besar Semester 4 - Mode Flexible', 'MOB-FLEX');

INSERT INTO "public"."workspaces" ("id", "project_id", "team_name", "topic_name", "progression_mode", "client_created_at") VALUES
('e1000001-0000-0000-0000-000000000000', 'a1000000-0000-0000-0000-000000000000', 'Tim Satu', 'Sistem E-Commerce UMKM', 'strict', now()),
('e1000002-0000-0000-0000-000000000000', 'a1000000-0000-0000-0000-000000000000', 'Tim Dua', 'Manajemen Keuangan Mahasiswa', 'strict', now()),
('e1000003-0000-0000-0000-000000000000', 'a1000000-0000-0000-0000-000000000000', 'Tim Tiga', 'Chatbot Layanan Publik', 'strict', now()),
('e1000004-0000-0000-0000-000000000000', 'a1000000-0000-0000-0000-000000000000', 'Tim Empat', 'Sistem Inventaris Gudang', 'strict', now()),
('e1000005-0000-0000-0000-000000000000', 'a1000000-0000-0000-0000-000000000000', 'Tim Lima', 'Booking Service Kendaraan', 'strict', now());

INSERT INTO "public"."workspaces" ("id", "project_id", "team_name", "topic_name", "progression_mode", "client_created_at") VALUES
('e2000001-0000-0000-0000-000000000000', 'a2000000-0000-0000-0000-000000000000', 'Tim Satu', 'Mobile Shop App', 'flexible', now()),
('e2000002-0000-0000-0000-000000000000', 'a2000000-0000-0000-0000-000000000000', 'Tim Dua', 'Finance Tracker Mobile', 'flexible', now()),
('e2000003-0000-0000-0000-000000000000', 'a2000000-0000-0000-0000-000000000000', 'Tim Tiga', 'Smart Assistant Mobile', 'flexible', now()),
('e2000004-0000-0000-0000-000000000000', 'a2000000-0000-0000-0000-000000000000', 'Tim Empat', 'Inventory Scan App', 'flexible', now()),
('e2000005-0000-0000-0000-000000000000', 'a2000000-0000-0000-0000-000000000000', 'Tim Lima', 'Vehicle Booking App', 'flexible', now());

-- WORKSPACE MEMBERS (Tetap per kelompok)
-- Kelompok 1: Prubaya(L), Bahlil, Gibran
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000001-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', true),
('e1000001-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', false),
('e1000001-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', false),
('e2000001-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', true),
('e2000001-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', false),
('e2000001-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', false);

-- Kelompok 2: Ganjar(L), Mahfud, Timothy
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000002-0000-0000-0000-000000000000', '33330004-0000-0000-0000-000000000000', true),
('e1000002-0000-0000-0000-000000000000', '33330005-0000-0000-0000-000000000000', false),
('e1000002-0000-0000-0000-000000000000', '33330006-0000-0000-0000-000000000000', false),
('e2000002-0000-0000-0000-000000000000', '33330004-0000-0000-0000-000000000000', true),
('e2000002-0000-0000-0000-000000000000', '33330005-0000-0000-0000-000000000000', false),
('e2000002-0000-0000-0000-000000000000', '33330006-0000-0000-0000-000000000000', false);

-- Kelompok 3: Anies(L), Cak Imin, Dadan-MBG
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000003-0000-0000-0000-000000000000', '33330007-0000-0000-0000-000000000000', true),
('e1000003-0000-0000-0000-000000000000', '33330008-0000-0000-0000-000000000000', false),
('e1000003-0000-0000-0000-000000000000', '33330009-0000-0000-0000-000000000000', false),
('e2000003-0000-0000-0000-000000000000', '33330007-0000-0000-0000-000000000000', true),
('e2000003-0000-0000-0000-000000000000', '33330008-0000-0000-0000-000000000000', false),
('e2000003-0000-0000-0000-000000000000', '33330009-0000-0000-0000-000000000000', false);

-- Kelompok 4: Zulhas(L), Amran Sulaiman, Luhut
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000004-0000-0000-0000-000000000000', '33330010-0000-0000-0000-000000000000', true),
('e1000004-0000-0000-0000-000000000000', '33330011-0000-0000-0000-000000000000', false),
('e1000004-0000-0000-0000-000000000000', '33330012-0000-0000-0000-000000000000', false),
('e2000004-0000-0000-0000-000000000000', '33330010-0000-0000-0000-000000000000', true),
('e2000004-0000-0000-0000-000000000000', '33330011-0000-0000-0000-000000000000', false),
('e2000004-0000-0000-0000-000000000000', '33330012-0000-0000-0000-000000000000', false);

-- Kelompok 5: Aldi Taher(L), Pigai, Tirta Pengpeng
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000005-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', true),
('e1000005-0000-0000-0000-000000000000', '33330014-0000-0000-0000-000000000000', false),
('e1000005-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', false),
('e2000005-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', true),
('e2000005-0000-0000-0000-000000000000', '33330014-0000-0000-0000-000000000000', false),
('e2000005-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', false);

-- 6. PROGRESS PHASES (8 Phases per Workspace)
-- Pola ID: f[ProjectNum][TeamNum][PhaseNum]
DO $$
DECLARE
    team_idx INT;
    phase_idx INT;
    phase_names TEXT[] := ARRAY[
        'Analisis Kebutuhan & ERD', 
        'UI/UX Design & Prototyping', 
        'Setup Environment & Database',
        'Implementasi Auth & Middleware',
        'Pengembangan Fitur Utama (Core)',
        'Integrasi API Eksternal',
        'Testing & Bug Fixing',
        'Deployment & Dokumentasi'
    ];
BEGIN
    FOR team_idx IN 1..5 LOOP
        FOR phase_idx IN 1..8 LOOP
            INSERT INTO "public"."progress_phases" ("id", "workspace_id", "phase_name", "sort_order", "status", "client_created_at")
            VALUES (
                CAST('b20' || team_idx || '000' || phase_idx || '-0000-0000-0000-000000000000' AS uuid),
                CAST('e100000' || team_idx || '-0000-0000-0000-000000000000' AS uuid),
                phase_names[phase_idx],
                phase_idx,
                CASE WHEN phase_idx < 3 THEN 'accepted'::approval_status ELSE 'pending'::approval_status END,
                now()
            );
        END LOOP;
    END LOOP;
END $$;

-- PROJECT 2 (MOBILE - FLEXIBLE)
DO $$
DECLARE
    team_idx INT;
    phase_idx INT;
    phase_names TEXT[] := ARRAY[
        'Wireframing & User Flow', 
        'High Fidelity Design', 
        'Project Init & Library Setup',
        'State Management Logic',
        'Integrasi Rest API',
        'Local Storage & Caching',
        'Unit & Integration Testing',
        'Final Review & Build APK'
    ];
BEGIN
    FOR team_idx IN 1..5 LOOP
        FOR phase_idx IN 1..8 LOOP
            INSERT INTO "public"."progress_phases" ("id", "workspace_id", "phase_name", "sort_order", "status", "client_created_at")
            VALUES (
                CAST('b30' || team_idx || '000' || phase_idx || '-0000-0000-0000-000000000000' AS uuid),
                CAST('e200000' || team_idx || '-0000-0000-0000-000000000000' AS uuid),
                phase_names[phase_idx],
                phase_idx,
                'pending',
                now()
            );
        END LOOP;
    END LOOP;
END $$;

-- TASK ALLOCATIONS (2-3 Tasks per Phase)
-- Kita contohkan pembagian tugas untuk TIM 1 (Prubaya, Bahlil, Gibran)

-- Tasks for TIM 1 (Project WEB - w1000001)
-- Phase 1 (b2010001)
INSERT INTO "public"."task_allocations" ("phase_id", "student_id", "task_description", "client_created_at") VALUES
('b2010001-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', 'Prubaya: Finalisasi dokumen SRS', now()),
('b2010001-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', 'Bahlil: Membuat Diagram ERD', now()),
('b2010001-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', 'Gibran: Membuat Use Case Diagram', now());

-- Phase 2 (b2010002)
INSERT INTO "public"."task_allocations" ("phase_id", "student_id", "task_description", "client_created_at") VALUES
('b2010002-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', 'Prubaya: Review Design System', now()),
('b2010002-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', 'Gibran: Membuat Prototype di Figma', now());

-- Phase 3 (b2010003)
INSERT INTO "public"."task_allocations" ("phase_id", "student_id", "task_description", "client_created_at") VALUES
('b2010003-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', 'Bahlil: Setup Docker & Database', now()),
('b2010003-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', 'Prubaya: Inisialisasi Repository GitHub', now());

-- Tasks for TIM 5 (Project MOBILE - w2000005)
-- Phase 1 (b3050001)
INSERT INTO "public"."task_allocations" ("phase_id", "student_id", "task_description", "client_created_at") VALUES
('b3050001-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', 'Aldi Taher: Membuat Flow Booking Kendaraan', now()),
('b3050001-0000-0000-0000-000000000000', '33330014-0000-0000-0000-000000000000', 'Pigai: Sketching UI Dashboard', now()),
('b3050001-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', 'Tirta: Research API Map Google', now());

-- Phase 4 (b3050004)
INSERT INTO "public"."task_allocations" ("phase_id", "student_id", "task_description", "client_created_at") VALUES
('b3050004-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', 'Aldi Taher: Implementasi Provider/Riverpod', now()),
('b3050004-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', 'Tirta: Binding data ke UI', now());