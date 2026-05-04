// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/academic/lecturer/view/lecturer_view.dart';

// --- IMPORT MODELS ---
import 'models/project_model.dart';
import 'models/workspace_model.dart';
import 'models/progress_phase_model.dart';
import 'models/user_model.dart';
import 'models/workspace_member_model.dart';
import 'models/task_allocation_model.dart';
import 'models/submission_model.dart';
import 'models/comment_model.dart';

// --- IMPORT SERVICES ---
import 'services/remote/project_service.dart';
import 'services/remote/workspace_service.dart';
import 'services/remote/phase_service.dart';
import 'services/remote/user_service.dart';
import 'services/remote/workspace_member_service.dart';
import 'services/remote/task_service.dart';
import 'services/remote/submission_service.dart';
import 'services/remote/comment_service.dart';

import 'services/local/project_local_service.dart';
import 'services/local/workspace_local_service.dart';
import 'services/local/phase_local_service.dart';
import 'services/local/user_local_service.dart';
import 'services/local/workspace_member_local_service.dart';
import 'services/local/task_local_service.dart';
import 'services/local/submission_local_service.dart';
import 'services/local/comment_local_service.dart';

// --- IMPORT REPOSITORIES ---
import 'repositories/project_repository.dart';
import 'repositories/workspace_repository.dart';
import 'repositories/phase_repository.dart';
import 'repositories/user_repository.dart';
import 'repositories/workspace_member_repository.dart';
import 'repositories/task_repository.dart';
import 'repositories/submission_repository.dart';
import 'repositories/comment_repository.dart';

// --- IMPORT CONTROLLERS BE ---
import 'controllers/lecturer/project_controller.dart';
import 'controllers/lecturer/topic_approval_controller.dart';
import 'controllers/lecturer/phase_approval_controller.dart';
import 'controllers/lecturer/progress_dashboard_controller.dart';
import 'controllers/lecturer/comment_controller.dart';
import 'controllers/lecturer/task_approval_controller.dart';
import 'controllers/lecturer/submission_review_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found.");
  }

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: ''),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: ''),
  );

  // INISIALISASI HIVE & ADAPTER
  await Hive.initFlutter();
  Hive.registerAdapter(ProjectModelAdapter());
  Hive.registerAdapter(WorkspaceModelAdapter());
  Hive.registerAdapter(ProgressPhaseModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(WorkspaceMemberModelAdapter());
  Hive.registerAdapter(TaskAllocationModelAdapter());
  Hive.registerAdapter(SubmissionModelAdapter());
  Hive.registerAdapter(CommentModelAdapter());

  // BUKA BOX HIVE
  final projectBox = await Hive.openBox<ProjectModel>('projects_box');
  final workspaceBox = await Hive.openBox<WorkspaceModel>('workspaces_box');
  final phaseBox = await Hive.openBox<ProgressPhaseModel>('phases_box');
  final userBox = await Hive.openBox<UserModel>('users_box');
  final memberBox = await Hive.openBox<WorkspaceMemberModel>(
    'workspace_members_box',
  );
  final taskBox = await Hive.openBox<TaskAllocationModel>('tasks_box');
  final submissionBox = await Hive.openBox<SubmissionModel>('submissions_box');
  final commentBox = await Hive.openBox<CommentModel>('comments_box');

  final supabaseClient = Supabase.instance.client;

  // SETUP REPOSITORIES
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

  runApp(
    MultiProvider(
      providers: [
        // STATE CONTROLLERS
        ChangeNotifierProvider(create: (_) => ProjectController(projectRepo)),
        ChangeNotifierProvider(
          create: (_) => TopicApprovalController(workspaceRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => PhaseApprovalController(phaseRepo),
        ),
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
        ChangeNotifierProvider(
          create: (_) => SubmissionReviewController(submissionRepo),
        ),
        // REPOSITORIES UNTUK DISEDOT WIDGET
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
      home: const LecturerView(),
    );
  }
}
