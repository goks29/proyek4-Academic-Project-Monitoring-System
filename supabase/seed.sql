-- ==========================================
-- 1. AUTH USERS (Internal Supabase)
-- ==========================================
-- Password: password123
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
)
VALUES
  ('d05e0001-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'andi@dosen.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('d05e0002-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'budi@dosen.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),

  ('33330001-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'andi@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330002-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'budi@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330003-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'citra@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330004-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dinda@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330005-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'eka@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330006-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'fajar@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330007-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'gita@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330008-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'hadi@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330009-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'intan@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330010-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'joko@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330011-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'kartika@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330012-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'lukman@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330013-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'maya@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330014-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'nanda@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', ''),
  ('33330015-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'oki@mhs.ac.id', extensions.crypt('password123', extensions.gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');


-- ==========================================
-- 2. PUBLIC USERS
-- ==========================================
INSERT INTO "public"."users" ("id", "full_name", "email", "password", "role") VALUES
('d05e0001-0000-0000-0000-000000000000', 'Dosen Andi', 'andi@dosen.ac.id', 'password123', 'lecturer'),
('d05e0002-0000-0000-0000-000000000000', 'Dosen Budi', 'budi@dosen.ac.id', 'password123', 'lecturer'),

('33330001-0000-0000-0000-000000000000', 'Andi', 'andi@mhs.ac.id', 'password123', 'student'),
('33330002-0000-0000-0000-000000000000', 'Budi', 'budi@mhs.ac.id', 'password123', 'student'),
('33330003-0000-0000-0000-000000000000', 'Citra', 'citra@mhs.ac.id', 'password123', 'student'),
('33330004-0000-0000-0000-000000000000', 'Dinda', 'dinda@mhs.ac.id', 'password123', 'student'),
('33330005-0000-0000-0000-000000000000', 'Eka', 'eka@mhs.ac.id', 'password123', 'student'),
('33330006-0000-0000-0000-000000000000', 'Fajar', 'fajar@mhs.ac.id', 'password123', 'student'),
('33330007-0000-0000-0000-000000000000', 'Gita', 'gita@mhs.ac.id', 'password123', 'student'),
('33330008-0000-0000-0000-000000000000', 'Hadi', 'hadi@mhs.ac.id', 'password123', 'student'),
('33330009-0000-0000-0000-000000000000', 'Intan', 'intan@mhs.ac.id', 'password123', 'student'),
('33330010-0000-0000-0000-000000000000', 'Joko', 'joko@mhs.ac.id', 'password123', 'student'),
('33330011-0000-0000-0000-000000000000', 'Kartika', 'kartika@mhs.ac.id', 'password123', 'student'),
('33330012-0000-0000-0000-000000000000', 'Lukman', 'lukman@mhs.ac.id', 'password123', 'student'),
('33330013-0000-0000-0000-000000000000', 'Maya', 'maya@mhs.ac.id', 'password123', 'student'),
('33330014-0000-0000-0000-000000000000', 'Nanda', 'nanda@mhs.ac.id', 'password123', 'student'),
('33330015-0000-0000-0000-000000000000', 'Oki', 'oki@mhs.ac.id', 'password123', 'student');


-- ==========================================
-- 3. PROJECTS
-- ==========================================
INSERT INTO "public"."projects" ("join_code", "lecturer_id", "title", "description") VALUES
('WEB-STRICT', 'd05e0001-0000-0000-0000-000000000000', 'Pengembangan Aplikasi Web', 'Tugas Besar Semester 4 - Mode Strict'),
('MOB-FLEX', 'd05e0002-0000-0000-0000-000000000000', 'Pengembangan Aplikasi Mobile', 'Tugas Besar Semester 4 - Mode Flexible');


-- ==========================================
-- 4. WORKSPACES (5 Tim x 2 Project)
-- ==========================================

-- Project Web (Strict)
INSERT INTO "public"."workspaces" ("id", "join_code", "team_name", "topic_name", "progression_mode", "client_created_at") VALUES
('e1000001-0000-0000-0000-000000000000', 'WEB-STRICT', 'Tim Satu', 'Sistem E-Commerce UMKM', 'strict', now()),
('e1000002-0000-0000-0000-000000000000', 'WEB-STRICT', 'Tim Dua', 'Manajemen Keuangan Mahasiswa', 'strict', now()),
('e1000003-0000-0000-0000-000000000000', 'WEB-STRICT', 'Tim Tiga', 'Chatbot Layanan Publik', 'strict', now()),
('e1000004-0000-0000-0000-000000000000', 'WEB-STRICT', 'Tim Empat', 'Sistem Inventaris Gudang', 'strict', now()),
('e1000005-0000-0000-0000-000000000000', 'WEB-STRICT', 'Tim Lima', 'Booking Service Kendaraan', 'strict', now());

-- Project Mobile (Flexible)
INSERT INTO "public"."workspaces" ("id", "join_code", "team_name", "topic_name", "progression_mode", "client_created_at") VALUES
('e2000001-0000-0000-0000-000000000000', 'MOB-FLEX', 'Tim Satu', 'Mobile Shop App', 'flexible', now()),
('e2000002-0000-0000-0000-000000000000', 'MOB-FLEX', 'Tim Dua', 'Finance Tracker Mobile', 'flexible', now()),
('e2000003-0000-0000-0000-000000000000', 'MOB-FLEX', 'Tim Tiga', 'Smart Assistant Mobile', 'flexible', now()),
('e2000004-0000-0000-0000-000000000000', 'MOB-FLEX', 'Tim Empat', 'Inventory Scan App', 'flexible', now()),
('e2000005-0000-0000-0000-000000000000', 'MOB-FLEX', 'Tim Lima', 'Vehicle Booking App', 'flexible', now());


-- ==========================================
-- 5. WORKSPACE MEMBERS (Tetap per kelompok)
-- ==========================================

-- Kelompok 1: Andi(L), Budi, Citra
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000001-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', true),
('e1000001-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', false),
('e1000001-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', false),
('e2000001-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', true),
('e2000001-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', false),
('e2000001-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', false);

-- Kelompok 2: Dinda(L), Eka, Fajar
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000002-0000-0000-0000-000000000000', '33330004-0000-0000-0000-000000000000', true),
('e1000002-0000-0000-0000-000000000000', '33330005-0000-0000-0000-000000000000', false),
('e1000002-0000-0000-0000-000000000000', '33330006-0000-0000-0000-000000000000', false),
('e2000002-0000-0000-0000-000000000000', '33330004-0000-0000-0000-000000000000', true),
('e2000002-0000-0000-0000-000000000000', '33330005-0000-0000-0000-000000000000', false),
('e2000002-0000-0000-0000-000000000000', '33330006-0000-0000-0000-000000000000', false);

-- Kelompok 3: Gita(L), Hadi, Intan
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000003-0000-0000-0000-000000000000', '33330007-0000-0000-0000-000000000000', true),
('e1000003-0000-0000-0000-000000000000', '33330008-0000-0000-0000-000000000000', false),
('e1000003-0000-0000-0000-000000000000', '33330009-0000-0000-0000-000000000000', false),
('e2000003-0000-0000-0000-000000000000', '33330007-0000-0000-0000-000000000000', true),
('e2000003-0000-0000-0000-000000000000', '33330008-0000-0000-0000-000000000000', false),
('e2000003-0000-0000-0000-000000000000', '33330009-0000-0000-0000-000000000000', false);

-- Kelompok 4: Joko(L), Kartika, Lukman
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000004-0000-0000-0000-000000000000', '33330010-0000-0000-0000-000000000000', true),
('e1000004-0000-0000-0000-000000000000', '33330011-0000-0000-0000-000000000000', false),
('e1000004-0000-0000-0000-000000000000', '33330012-0000-0000-0000-000000000000', false),
('e2000004-0000-0000-0000-000000000000', '33330010-0000-0000-0000-000000000000', true),
('e2000004-0000-0000-0000-000000000000', '33330011-0000-0000-0000-000000000000', false),
('e2000004-0000-0000-0000-000000000000', '33330012-0000-0000-0000-000000000000', false);

-- Kelompok 5: Maya(L), Nanda, Oki
INSERT INTO "public"."workspace_members" ("workspace_id", "student_id", "is_leader") VALUES
('e1000005-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', true),
('e1000005-0000-0000-0000-000000000000', '33330014-0000-0000-0000-000000000000', false),
('e1000005-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', false),
('e2000005-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', true),
('e2000005-0000-0000-0000-000000000000', '33330014-0000-0000-0000-000000000000', false),
('e2000005-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', false);


-- =============================================================================
-- 6. PROGRESS PHASES (8 Phases per Workspace)
-- Pola ID: f[ProjectNum][TeamNum][PhaseNum]
-- =============================================================================

-- PROJECT 1 (WEB - STRICT)
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
            INSERT INTO "public"."progress_phases" (
                "id",
                "workspace_id",
                "phase_name",
                "sort_order",
                "status",
                "client_created_at"
            )
            VALUES (
                CAST('b20' || team_idx || '000' || phase_idx || '-0000-0000-0000-000000000000' AS uuid),
                CAST('e100000' || team_idx || '-0000-0000-0000-000000000000' AS uuid),
                phase_names[phase_idx],
                phase_idx,
                CASE
                    WHEN phase_idx < 3 THEN 'accepted'::approval_status
                    ELSE 'pending'::approval_status
                END,
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
            INSERT INTO "public"."progress_phases" (
                "id",
                "workspace_id",
                "phase_name",
                "sort_order",
                "status",
                "client_created_at"
            )
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


-- =============================================================================
-- 7. TASK ALLOCATIONS (2-3 Tasks per Phase)
-- Contoh pembagian tugas untuk Tim 1 dan Tim 5
-- =============================================================================

-- Tasks for TIM 1 (Project WEB - e1000001)
-- Phase 1 (b2010001)
INSERT INTO "public"."task_allocations" (
    "phase_id",
    "student_id",
    "task_description",
    "client_created_at"
)
VALUES
('b2010001-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', 'Andi: Finalisasi dokumen SRS', now()),
('b2010001-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', 'Budi: Membuat Diagram ERD', now()),
('b2010001-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', 'Citra: Membuat Use Case Diagram', now());


-- Phase 2 (b2010002)
INSERT INTO "public"."task_allocations" (
    "phase_id",
    "student_id",
    "task_description",
    "client_created_at"
)
VALUES
('b2010002-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', 'Andi: Review Design System', now()),
('b2010002-0000-0000-0000-000000000000', '33330003-0000-0000-0000-000000000000', 'Citra: Membuat Prototype di Figma', now());


-- Phase 3 (b2010003)
INSERT INTO "public"."task_allocations" (
    "phase_id",
    "student_id",
    "task_description",
    "client_created_at"
)
VALUES
('b2010003-0000-0000-0000-000000000000', '33330002-0000-0000-0000-000000000000', 'Budi: Setup Docker & Database', now()),
('b2010003-0000-0000-0000-000000000000', '33330001-0000-0000-0000-000000000000', 'Andi: Inisialisasi Repository GitHub', now());


-- Tasks for TIM 5 (Project MOBILE - e2000005)
-- Phase 1 (b3050001)
INSERT INTO "public"."task_allocations" (
    "phase_id",
    "student_id",
    "task_description",
    "client_created_at"
)
VALUES
('b3050001-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', 'Maya: Membuat Flow Booking Kendaraan', now()),
('b3050001-0000-0000-0000-000000000000', '33330014-0000-0000-0000-000000000000', 'Nanda: Sketching UI Dashboard', now()),
('b3050001-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', 'Oki: Research API Map Google', now());


-- Phase 4 (b3050004)
INSERT INTO "public"."task_allocations" (
    "phase_id",
    "student_id",
    "task_description",
    "client_created_at"
)
VALUES
('b3050004-0000-0000-0000-000000000000', '33330013-0000-0000-0000-000000000000', 'Maya: Implementasi Provider/Riverpod', now()),
('b3050004-0000-0000-0000-000000000000', '33330015-0000-0000-0000-000000000000', 'Oki: Binding data ke UI', now());