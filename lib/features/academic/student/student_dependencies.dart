// lib/features/academic/student/student_dependencies.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// --- IMPORT CONTROLLERS ---
import 'controller/workspace_controller.dart';
import 'controller/workspace_detail_controller.dart';
import 'controller/workspace_task_controller.dart';

class StudentDependencies {
  // Rakit semua Provider Student
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => WorkspaceController()),
      ChangeNotifierProvider(create: (_) => WorkspaceDetailController()),
      ChangeNotifierProvider(create: (_) => WorkspaceTaskController()),
    ];
  }
}
