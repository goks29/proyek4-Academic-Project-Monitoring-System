# Academic Project Monitoring System

> Sistem monitoring proyek akademik berbasis Flutter & Supabase untuk memantau progres tugas akhir mahasiswa secara real-time dengan dukungan **offline-first** dan sinkronisasi otomatis.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?logo=supabase&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-Local_Storage-orange)

---

## Deskripsi Singkat

**Academic Project Monitoring System** adalah aplikasi mobile yang dirancang untuk mempermudah proses monitoring dan pengelolaan proyek akademik antara **dosen** dan **mahasiswa** di lingkungan Politeknik Negeri Bandung (POLBAN).

Aplikasi ini memungkinkan:

- **Dosen** membuat proyek, menyetujui topik & fase, mereview submission, serta memantau progress keseluruhan tim.
- **Mahasiswa** membuat workspace (kelompok), menentukan topik, membagi tugas per fase, mengumpulkan bukti pengerjaan, dan berkolaborasi antar anggota tim.

---

## Fitur-fitur Utama

### - Mahasiswa
- **Bergabung ke proyek** menggunakan kode unik (*join code*)
- **Membuat workspace** (kelompok kerja) dan mengundang anggota tim
- **Mengajukan topik** beserta deskripsi untuk persetujuan dosen
- **Mengelola fase progres** (*progress phases*) secara berurutan
- **Pembagian tugas** (*task allocation*) per anggota per fase
- **Submit persentase progres & bukti pengerjaan** dengan upload file/gambar
- **Mode offline** yaitu submit tetap bisa dilakukan tanpa koneksi internet, data akan otomatis disinkronkan saat kembali online

### - Dosen 
- **Membuat dan mengelola proyek** dengan deskripsi & kode join
- **Menyetujui/menolak topik** workspace dengan feedback
- **Mereview & approve fase progres** beserta komentar
- **Mereview tugas dan submission** mahasiswa
- **Dashboard progress** untuk memantau semua workspace dalam satu proyek
- **Komentar dan feedback** langsung pada fase atau tugas

### - Teknis
- **Offline-first architecture** dengan Hive untuk penyimpanan lokal
- **Auto-sync** saat koneksi internet kembali tersedia
- **Role-based access control** (student / lecturer)

---

## Arsitektur

Aplikasi ini menggunakan arsitektur **MVC (Model-View-Controller)** untuk memisahkan logika dan tampilan dengan menerapkan **Clean Code**.

```
┌──────────────────────────────────────────────────────┐
│                      Views (UI)                      │
├──────────────────────────────────────────────────────┤
│                    Controllers                       │
│              (ChangeNotifier + Provider)             │
├──────────────────────────────────────────────────────┤
│                   Repositories                       │
│            (Abstraksi Remote + Local)                │
├─────────────────────┬────────────────────────────────┤
│   Remote Services   │        Local Services          │
│    (Supabase API)   │     (Hive Local Storage)       │
└─────────────────────┴────────────────────────────────┘
```

---

## Struktur Proyek

```
lib/
├── main.dart                          # Entry point & dependency injection
├── core/
│   ├── offline/                       # Infrastruktur offline
│   │   ├── connectivity_monitor.dart  # Monitor koneksi internet
│   │   ├── monotonic_clock_service.dart
│   │   ├── offline_submission_manager.dart
│   │   └── session_token_manager.dart
│   └── sync/
│       └── sync_manager.dart          # Sinkronisasi data offline → remote
├── models/                            # Data models (Hive-compatible)
│   ├── user_model.dart
│   ├── project_model.dart
│   ├── workspace_model.dart
│   ├── workspace_member_model.dart
│   ├── progress_phase_model.dart
│   ├── task_allocation_model.dart
│   ├── submission_model.dart
│   ├── comment_model.dart
│   ├── session_token_model.dart
│   ├── pending_submission_model.dart
│   └── sync_action_model.dart
├── services/
│   ├── remote/                        # Supabase API services
│   │   ├── user_service.dart
│   │   ├── project_service.dart
│   │   ├── workspace_service.dart
│   │   ├── workspace_member_service.dart
│   │   ├── phase_service.dart
│   │   ├── task_service.dart
│   │   ├── submission_service.dart
│   │   └── comment_service.dart
│   └── local/                         # Hive local storage services
│       ├── user_local_service.dart
│       ├── project_local_service.dart
│       ├── workspace_local_service.dart
│       ├── workspace_member_local_service.dart
│       ├── phase_local_service.dart
│       ├── task_local_service.dart
│       ├── submission_local_service.dart
│       ├── comment_local_service.dart
│       └── sync_action_local_service.dart
├── repositories/                      # Repository pattern (remote + local)
│   ├── user_repository.dart
│   ├── project_repository.dart
│   ├── workspace_repository.dart
│   ├── workspace_member_repository.dart
│   ├── phase_repository.dart
│   ├── task_repository.dart
│   ├── submission_repository.dart
│   └── comment_repository.dart
├── controllers/
│   └── lecturer/                      # Lecturer-specific controllers
│       ├── project_controller.dart
│       ├── topic_approval_controller.dart
│       ├── phase_approval_controller.dart
│       ├── task_approval_controller.dart
│       ├── submission_review_controller.dart
│       ├── comment_controller.dart
│       └── progress_dashboard_controller.dart
└── features/academic/
    ├── auth/
    │   ├── login_controller.dart
    │   └── login_view.dart
    ├── student/
    │   ├── controller/
    │   │   ├── workspace_controller.dart
    │   │   ├── workspace_detail_controller.dart
    │   │   └── workspace_task_controller.dart
    │   └── view/
    │       ├── student_view.dart
    │       ├── home_page.dart
    │       ├── workspace_home_view.dart
    │       ├── workspace_create_view.dart
    │       ├── workspace_join_view.dart
    │       ├── workspace_detail_view.dart
    │       ├── workspace_task_view.dart
    │       └── phase_task_setup_page.dart
    └── lecturer/
        ├── view/
        │   ├── lecturer_view.dart
        │   ├── add_project_view.dart
        │   ├── workspace_detail_view.dart
        │   ├── phase_detail_view.dart
        │   └── profile_view.dart
        └── widgets/
            ├── dashboard_stats.dart
            ├── lecturer_header.dart
            ├── lecturer_bottom_nav.dart
            ├── project_list_widget.dart
            ├── project_input_field.dart
            ├── workspace_list_widget.dart
            ├── workspace_widget.dart
            ├── workspace_profile_widget.dart
            ├── workspace_progress_widget.dart
            ├── task_list_widget.dart
            ├── submission_list_widget.dart
            ├── phase_comment_widget.dart
            ├── search_bar_widget.dart
            └── success_code_box.dart

supabase/
├── config.toml                        # Konfigurasi Supabase lokal
├── seed.sql                           # Data seed untuk development
└── migrations/                        # Database migrations
    ├── 20260423154027_create_database_schema.sql
    ├── 20260501080000_add_workspace_rpc_functions.sql
    ├── 20260501090000_make_project_id_nullable.sql
    ├── 20260517050000_fix_submissions_evidence_url.sql
    ├── 20260524091407_update_storage_policy.sql
    ├── 20260525090000_add_offline_submission_support.sql
    └── 20260607175000_disable_all_rls.sql
```

---

## Prasyarat

Pastikan Anda sudah menginstall:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi ≥ 3.x)
- [Dart SDK](https://dart.dev/get-dart) (versi ≥ 3.11.1)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (opsional untuk pengembangan lokal)
- Android Studio / VS Code dengan Flutter extension

---

## Instalasi & Setup

### 1. Clone Repository

```bash
git clone https://github.com/goks29/proyek4-Academic-Project-Monitoring-System.git
cd proyek4-Academic-Project-Monitoring-System
```

### 2. Konfigurasi Environment

Buat file `.env` di root project:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> **Catatan**: Jangan commit file `.env` ke repository. File ini sudah ada di `.gitignore`.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Hive Adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Setup Supabase

#### Opsi A: Menggunakan Supabase Cloud
1. Buat proyek baru di [Supabase Dashboard](https://supabase.com/dashboard)
2. Jalankan migration SQL di SQL Editor secara berurutan dari folder `supabase/migrations/`
3. (Opsional) Jalankan `supabase/seed.sql` untuk data sample

#### Opsi B: Menggunakan Supabase Lokal
```bash
supabase start
supabase db reset   # Otomatis menjalankan migrations & seed
```

### 6. Jalankan Aplikasi

```bash
flutter run
```

---

## Testing

Proyek ini memiliki unit test untuk controller:

```bash
# Jalankan semua test
flutter test

# Jalankan test spesifik
flutter test test/workspaces_controller_test.dart
flutter test test/workspaces_detail_controller_test.dart
flutter test test/workspaces_task_controller_test.dart
flutter test test/lecturer_project_controller_test.dart
flutter test test/lecturer_topic_approval_controller_test.dart
flutter test test/lecturer_phase_approval_controller_test.dart
flutter test test/lecturer_task_approval_controller_test.dart
flutter test test/lecturer_submission_review_controller_test.dart
flutter test test/lecturer_comment_controller_test.dart
flutter test test/lecturer_progress_dashboard_controller_test.dart
```

### Cakupan Test

| Controller                      | Test File                                             |
|---------------------------------|-------------------------------------------------------|
| `WorkspaceController`           | `workspaces_controller_test.dart`                     |
| `WorkspaceDetailController`     | `workspaces_detail_controller_test.dart`              |
| `WorkspaceTaskController`       | `workspaces_task_controller_test.dart`                |
| `ProjectController`             | `lecturer_project_controller_test.dart`               |
| `TopicApprovalController`       | `lecturer_topic_approval_controller_test.dart`        |
| `PhaseApprovalController`       | `lecturer_phase_approval_controller_test.dart`        |
| `TaskApprovalController`        | `lecturer_task_approval_controller_test.dart`         |
| `SubmissionReviewController`    | `lecturer_submission_review_controller_test.dart`     |
| `CommentController`             | `lecturer_comment_controller_test.dart`               |
| `ProgressDashboardController`   | `lecturer_progress_dashboard_controller_test.dart`    |

---

## Tech Stack

| Kategori          | Teknologi                                                    |
|-------------------|--------------------------------------------------------------|
| **Framework**     | Flutter 3.x (Dart 3.x)                                       |
| **Backend**       | Supabase (PostgreSQL, Auth, Storage)                         |
| **State Mgmt**    | Provider + ChangeNotifier                                    |
| **Local Storage** | Hive (NoSQL) + Flutter Secure Storage                        |
| **Offline Sync**  | Custom sync engine (ConnectivityMonitor + SyncManager)       |
| **Networking**    | Supabase Flutter SDK                                         |
| **Image Upload**  | Image Picker + Supabase Bucket Storage                       |
| **Code Gen**      | build_runner + hive_generator                                |
| **Testing**       | flutter_test + mocktail                                      |

---

## Tim Pengembang

Proyek ini dikembangkan sebagai bagian dari **Mata Kuliah Proyek 4** di Politeknik Negeri Bandung (POLBAN) dengan anggota:

- Arnold Billy Kresnawan (241511003)
- Christian Goklas Natanael Sitorus (241511005)
- Muhammad Faliq Shiddiq Azzaki (241511017)
- Muhammad Hanif (241511018)