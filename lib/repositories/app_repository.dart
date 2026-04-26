import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/workspace_service.dart';
import '../services/phase_service.dart';
import '../services/task_service.dart';
import '../services/project_service.dart';
import '../services/submission_service.dart';
import '../services/comment_service.dart';
import '../services/user_service.dart';
import '../services/workspace_member_service.dart';

/// Main repository facade.
///
/// Provides a single entry point to access all Supabase database services.
class AppRepository {
  final WorkspaceService workspace;
  final PhaseService phase;
  final TaskService task;
  final ProjectService project;
  final SubmissionService submission;
  final CommentService comment;
  final UserService user;
  final WorkspaceMemberService member;

  AppRepository._({
    required this.workspace,
    required this.phase,
    required this.task,
    required this.project,
    required this.submission,
    required this.comment,
    required this.user,
    required this.member,
  });

  /// Initializes all services with the provided [SupabaseClient].
  factory AppRepository.create(SupabaseClient client) {
    return AppRepository._(
      workspace: WorkspaceService(client),
      phase: PhaseService(client),
      task: TaskService(client),
      project: ProjectService(client),
      submission: SubmissionService(client),
      comment: CommentService(client),
      user: UserService(client),
      member: WorkspaceMemberService(client),
    );
  }
}
