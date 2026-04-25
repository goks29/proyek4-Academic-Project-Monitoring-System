import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:academic_project_monitoring_system/features/academic/student/model/workspace_model.dart';
import 'package:academic_project_monitoring_system/features/academic/student/student_view.dart';

void main() async {
  Hive.registerAdapter(WorkspaceModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StudentView(),
    );
  }
}
