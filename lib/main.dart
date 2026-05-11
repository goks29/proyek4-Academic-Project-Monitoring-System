// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- VIEWS ---
import 'package:academic_project_monitoring_system/features/academic/auth/login_view.dart';
import 'package:academic_project_monitoring_system/features/academic/student/student_view.dart';
import 'package:academic_project_monitoring_system/features/academic/lecturer/view/lecturer_view.dart';

// --- MODELS ---
import 'package:academic_project_monitoring_system/models/comment_model.dart';
import 'package:academic_project_monitoring_system/models/progress_phase_model.dart';
import 'package:academic_project_monitoring_system/models/project_model.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'package:academic_project_monitoring_system/models/sync_action_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';

// --- SERVICES (REMOTE) ---
import 'package:academic_project_monitoring_system/services/remote/comment_service.dart';
import 'package:academic_project_monitoring_system/services/remote/phase_service.dart';
import 'package:academic_project_monitoring_system/services/remote/project_service.dart';
import 'package:academic_project_monitoring_system/services/remote/submission_service.dart';
import 'package:academic_project_monitoring_system/services/remote/task_service.dart';
import 'package:academic_project_monitoring_system/services/remote/user_service.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_member_service.dart';
import 'package:academic_project_monitoring_system/services/remote/workspace_service.dart';

// --- SERVICES (LOCAL) ---
import 'package:academic_project_monitoring_system/services/local/comment_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/phase_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/project_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/submission_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/task_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/user_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/workspace_local_service.dart';
import 'package:academic_project_monitoring_system/services/local/workspace_member_local_service.dart';

// --- REPOSITORIES ---
import 'package:academic_project_monitoring_system/repositories/comment_repository.dart';
import 'package:academic_project_monitoring_system/repositories/phase_repository.dart';
import 'package:academic_project_monitoring_system/repositories/project_repository.dart';
import 'package:academic_project_monitoring_system/repositories/submission_repository.dart';
import 'package:academic_project_monitoring_system/repositories/task_repository.dart';
import 'package:academic_project_monitoring_system/repositories/user_repository.dart';
import 'package:academic_project_monitoring_system/repositories/workspace_member_repository.dart';
import 'package:academic_project_monitoring_system/repositories/workspace_repository.dart';

// --- CONTROLLERS ---
import 'package:academic_project_monitoring_system/features/academic/auth/login_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_detail_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_task_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/comment_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/phase_approval_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/progress_dashboard_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/project_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/submission_review_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/task_approval_controller.dart';
import 'package:academic_project_monitoring_system/controllers/lecturer/topic_approval_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found. $e");
  }

  // 2. Inisialisasi Hive
  await Hive.initFlutter();

  // Register semua adapter
  Hive.registerAdapter(WorkspaceModelAdapter());
  Hive.registerAdapter(WorkspaceMemberModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProjectModelAdapter());
  Hive.registerAdapter(TaskAllocationModelAdapter());
  Hive.registerAdapter(SyncActionModelAdapter());
  Hive.registerAdapter(ProgressPhaseModelAdapter());
  Hive.registerAdapter(SubmissionModelAdapter());
  Hive.registerAdapter(CommentModelAdapter());

  // Buka semua box
  final projectBox = await Hive.openBox<ProjectModel>('projects_box');
  final workspaceBox = await Hive.openBox<WorkspaceModel>('workspaces_box');
  final phaseBox = await Hive.openBox<ProgressPhaseModel>('phases_box');
  final userBox = await Hive.openBox<UserModel>('users_box');
  final memberBox = await Hive.openBox<WorkspaceMemberModel>('workspace_members_box');
  final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
  final submissionBox = await Hive.openBox<SubmissionModel>('submissions_box');
  final commentBox = await Hive.openBox<CommentModel>('comments_box');

  // 3. Inisialisasi Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: ''),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
  );

  final supabaseClient = Supabase.instance.client;

  // 4. Setup Repositories
  final projectRepo = ProjectRepository(
    ProjectService(supabaseClient),
    ProjectLocalService(projectBox),
  );
  final workspaceRepo = WorkspaceRepository(
    WorkspaceService(supabaseClient),
    WorkspaceLocalService(workspaceBox),
  );
  final phaseRepo = PhaseRepository(
    PhaseService(supabaseClient),
    PhaseLocalService(phaseBox),
  );
  final userRepo = UserRepository(
    UserService(supabaseClient),
    UserLocalService(userBox),
  );
  final memberRepo = WorkspaceMemberRepository(
    WorkspaceMemberService(supabaseClient),
    WorkspaceMemberLocalService(memberBox),
  );
  final taskRepo = TaskRepository(
    TaskService(supabaseClient),
    TaskLocalService(taskBox),
  );
  final submissionRepo = SubmissionRepository(
    SubmissionService(supabaseClient),
    SubmissionLocalService(submissionBox),
  );
  final commentRepo = CommentRepository(
    CommentService(supabaseClient),
    CommentLocalService(commentBox),
  );

  // 5. Jalankan App
  runApp(
    MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(create: (_) => LoginController()..checkSession()),

        // Student Controllers
        ChangeNotifierProvider(create: (_) => WorkspaceController()),
        ChangeNotifierProvider(create: (_) => WorkspaceDetailController()),
        ChangeNotifierProvider(create: (_) => WorkspaceTaskController()),

        // Lecturer Controllers
        ChangeNotifierProvider(create: (_) => ProjectController(projectRepo)),
        ChangeNotifierProvider(create: (_) => TopicApprovalController(workspaceRepo)),
        ChangeNotifierProvider(create: (_) => PhaseApprovalController(phaseRepo)),
        ChangeNotifierProvider(
          create: (_) => ProgressDashboardController(
            workspaceRepo,
            memberRepo,
            phaseRepo,
            taskRepo,
          ),
        ),
        ChangeNotifierProvider(create: (_) => CommentController(commentRepo)),
        ChangeNotifierProvider(create: (_) => TaskApprovalController(taskRepo)),
        ChangeNotifierProvider(create: (_) => SubmissionReviewController(submissionRepo)),

        // Repositories (untuk diakses langsung oleh widget jika perlu)
        Provider<UserRepository>(create: (_) => userRepo),
        Provider<WorkspaceMemberRepository>(create: (_) => memberRepo),
        Provider<TaskRepository>(create: (_) => taskRepo),
        Provider<SubmissionRepository>(create: (_) => submissionRepo),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polban Learning Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: Consumer<LoginController>(
        builder: (context, controller, _) {
          // Tampilkan loading saat cek sesi
          if (controller.isCheckingSession) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Routing berdasarkan role
          if (controller.currentUser != null) {
            final role = controller.currentUser?.role;
            if (role == 'student') return StudentView();
            if (role == 'lecturer') return LecturerView();
          }

          // Default: halaman login
          return LoginView();
        },
      ),
    );
  }
}