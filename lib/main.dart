import 'package:academic_project_monitoring_system/features/academic/student/student_view.dart';
import 'package:academic_project_monitoring_system/models/project_model.dart';
import 'package:academic_project_monitoring_system/models/sync_action_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/workspace_member_model.dart';
import 'package:provider/provider.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/auth/login_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/auth/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env
  await dotenv.load(fileName: ".env");

  // Inisialisasi Hive
  await Hive.initFlutter();

  await Hive.deleteFromDisk();

  Hive.registerAdapter(WorkspaceModelAdapter());
  Hive.registerAdapter(WorkspaceMemberModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProjectModelAdapter());         
  Hive.registerAdapter(TaskAllocationModelAdapter());  
  Hive.registerAdapter(SyncActionModelAdapter());

  await Hive.openBox<WorkspaceModel>('workspaces');
  await Hive.openBox<WorkspaceMemberModel>('workspace_members');
  await Hive.openBox<UserModel>('user_profile');

  // Initialisasi Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginController()..checkSession()),
          ChangeNotifierProvider(create: (_) => WorkspaceController()),
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Consumer<LoginController>(
        builder: (context, controller, _) {
          if (controller.isCheckingSession) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.currentUser != null) {
            final role = controller.currentUser?.role;
            if (role == 'student') return StudentView();
            // if (role == 'lecturer') return ; // Jangan lupa diisi return kemana @tim-backend-dosen
          }
          return LoginView();
        },
      ),
    );
  }
}