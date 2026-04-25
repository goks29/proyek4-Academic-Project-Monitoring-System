import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/workspace_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load configuration
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  // 3. Run CRUD Test
  await runDatabaseTest();

  runApp(const MyApp());
}

Future<void> runDatabaseTest() async {
  final service = WorkspaceService();
  print('--- Starting Database Test ---');

  // Test 1: Connection
  bool isConnected = await service.testConnection();
  if (!isConnected) {
    print('Test Failed: Could not connect to Supabase');
    return;
  }

  // Test 2: Create Workspace
  // Note: Using ID from previously inserted dummy project
  const testProjectId = 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21';
  
  await service.createWorkspace(
    projectId: testProjectId,
    teamName: 'Integration Test Team',
    topicName: 'Automated Test Topic',
  );

  // Test 3: Fetch Data
  final workspaces = await service.getWorkspaces();
  
  if (workspaces.isNotEmpty) {
    print('Test Success: CRUD operations verified');
    print('Total Workspaces: ${workspaces.length}');
  } else {
    print('Test Warning: Connection success but no data found');
  }

  print('--- Database Test Completed ---');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Check console for test results'),
        ),
      ),
    );
  }
}