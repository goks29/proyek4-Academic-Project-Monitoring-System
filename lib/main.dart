import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/features/academic/lecturer/lecturer_view.dart';

void main() {
  // runApp(const MyApp());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academik Project Monitoring System',

      initialRoute: '/dashboardDosen',
      routes: {'/dashboardDosen': (context) => LecturerView()},
    );
  }
}
