// lib/features/academic/lecturer/lecturer_dependencies.dart
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT MODELS ---
import '../../../models/project_model.dart';
import '../../../models/workspace_model.dart';
import '../../../models/progress_phase_model.dart';
import '../../../models/user_model.dart';
import '../../../models/workspace_member_model.dart';
import '../../../models/task_allocation_model.dart';
import '../../../models/submission_model.dart';
import '../../../models/comment_model.dart';

// --- IMPORT SERVICES ---
import '../../../services/remote/project_service.dart';
import '../../../services/remote/workspace_service.dart';
import '../../../services/remote/phase_service.dart';
import '../../../services/remote/user_service.dart';
import '../../../services/remote/workspace_member_service.dart';
import '../../../services/remote/task_service.dart';
import '../../../services/remote/submission_service.dart';
import '../../../services/remote/comment_service.dart';
import '../../../services/local/project_local_service.dart';
import '../../../services/local/workspace_local_service.dart';
import '../../../services/local/phase_local_service.dart';
import '../../../services/local/user_local_service.dart';
import '../../../services/local/workspace_member_local_service.dart';
import '../../../services/local/task_local_service.dart';
import '../../../services/local/submission_local_service.dart';
import '../../../services/local/comment_local_service.dart';

// --- IMPORT REPOSITORIES ---
import '../../../repositories/project_repository.dart';
import '../../../repositories/workspace_repository.dart';
import '../../../repositories/phase_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../repositories/workspace_member_repository.dart';
import '../../../repositories/task_repository.dart';
import '../../../repositories/submission_repository.dart';
import '../../../repositories/comment_repository.dart';

// --- IMPORT CONTROLLERS ---
import '../../../controllers/lecturer/project_controller.dart';
import '../../../controllers/lecturer/topic_approval_controller.dart';
import '../../../controllers/lecturer/phase_approval_controller.dart';
import '../../../controllers/lecturer/progress_dashboard_controller.dart';
import '../../../controllers/lecturer/comment_controller.dart';
import '../../../controllers/lecturer/task_approval_controller.dart';
import '../../../controllers/lecturer/submission_review_controller.dart';

class LecturerDependencies {
  // 1. Inisialisasi Database Lokal Dosen
  static Future<void> initHive() async {
    Hive.registerAdapter(ProjectModelAdapter());
    Hive.registerAdapter(ProgressPhaseModelAdapter());
    Hive.registerAdapter(TaskAllocationModelAdapter());
    Hive.registerAdapter(SubmissionModelAdapter());
    Hive.registerAdapter(CommentModelAdapter());

    await Hive.openBox<ProjectModel>('projects_box');
    await Hive.openBox<WorkspaceModel>('workspaces_box');
    await Hive.openBox<ProgressPhaseModel>('phases_box');
    await Hive.openBox<UserModel>('users_box');
    await Hive.openBox<WorkspaceMemberModel>('workspace_members_box');
    await Hive.openBox<TaskAllocationModel>('tasks_box');
    await Hive.openBox<SubmissionModel>('submissions_box');
    await Hive.openBox<CommentModel>('comments_box');
  }

  // 2. Rakit semua Provider Dosen
  static List<SingleChildWidget> getProviders() {
    final supabaseClient = Supabase.instance.client;

    // Ambil Box
    final projectBox = Hive.box<ProjectModel>('projects_box');
    final workspaceBox = Hive.box<WorkspaceModel>('workspaces_box');
    final phaseBox = Hive.box<ProgressPhaseModel>('phases_box');
    final userBox = Hive.box<UserModel>('users_box');
    final memberBox = Hive.box<WorkspaceMemberModel>('workspace_members_box');
    final taskBox = Hive.box<TaskAllocationModel>('tasks_box');
    final submissionBox = Hive.box<SubmissionModel>('submissions_box');
    final commentBox = Hive.box<CommentModel>('comments_box');

    // Rakit Repository
    final projectRepo = ProjectRepository(ProjectService(supabaseClient), ProjectLocalService(projectBox));
    final workspaceRepo = WorkspaceRepository(WorkspaceService(supabaseClient), WorkspaceLocalService(workspaceBox));
    final phaseRepo = PhaseRepository(PhaseService(supabaseClient), PhaseLocalService(phaseBox));
    final userRepo = UserRepository(UserService(supabaseClient), UserLocalService(userBox));
    final memberRepo = WorkspaceMemberRepository(WorkspaceMemberService(supabaseClient), WorkspaceMemberLocalService(memberBox));
    final taskRepo = TaskRepository(TaskService(supabaseClient), TaskLocalService(taskBox));
    final submissionRepo = SubmissionRepository(SubmissionService(supabaseClient), SubmissionLocalService(submissionBox));
    final commentRepo = CommentRepository(CommentService(supabaseClient), CommentLocalService(commentBox));

    // Kembalikan daftar Provider
    return [
      ChangeNotifierProvider(create: (_) => ProjectController(projectRepo)),
      ChangeNotifierProvider(create: (_) => TopicApprovalController(workspaceRepo)),
      ChangeNotifierProvider(create: (_) => PhaseApprovalController(phaseRepo)),
      ChangeNotifierProvider(create: (_) => ProgressDashboardController(workspaceRepo, memberRepo, phaseRepo, taskRepo)),
      ChangeNotifierProvider(create: (_) => CommentController(commentRepo)),
      ChangeNotifierProvider(create: (_) => TaskApprovalController(taskRepo)),
      ChangeNotifierProvider(create: (_) => SubmissionReviewController(submissionRepo)),
      
      Provider<UserRepository>(create: (_) => userRepo),
      Provider<WorkspaceMemberRepository>(create: (_) => memberRepo),
      Provider<TaskRepository>(create: (_) => taskRepo),
      Provider<SubmissionRepository>(create: (_) => submissionRepo),
    ];
  }
}