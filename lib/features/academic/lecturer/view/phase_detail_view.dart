// lib/features/academic/lecturer/view/phase_detail_view.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/progress_phase_model.dart';
import '../../../../models/workspace_model.dart';
import '../../../../models/task_allocation_model.dart';
import '../../../../models/submission_model.dart';

// Import Service
import '../../../../services/remote/task_service.dart';
import '../../../../services/remote/submission_service.dart';

// Import Component/Widgets 
import '../widgets/submission_list_widget.dart';
import '../widgets/task_list_widget.dart';

class PhaseDetailView extends StatefulWidget {
  final ProgressPhaseModel phase;
  final WorkspaceModel workspace;

  const PhaseDetailView({
    super.key,
    required this.phase,
    required this.workspace,
  });

  @override
  State<PhaseDetailView> createState() => _PhaseDetailViewState();
}

class _PhaseDetailViewState extends State<PhaseDetailView> {
  late Future<Map<String, dynamic>> _phaseDataFuture;
  
  final TaskService _taskService = TaskService(Supabase.instance.client);
  final SubmissionService _submissionService = SubmissionService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _phaseDataFuture = _fetchPhaseData();
  }

  Future<Map<String, dynamic>> _fetchPhaseData() async {
    final results = await Future.wait([
      _taskService.getTasks(widget.phase.id),
      _submissionService.getSubmissions(widget.phase.id),
    ]);

    return {
      'tasks': results[0] as List<TaskAllocationModel>,
      'submissions': results[1] as List<SubmissionModel>,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detail ${widget.phase.phaseName}",
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.workspace.teamName,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _phaseDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan jaringan: ${snapshot.error}"));
          }

          final tasks = snapshot.data!['tasks'] as List<TaskAllocationModel>;
          final submissions = snapshot.data!['submissions'] as List<SubmissionModel>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hasil Kerja Mahasiswa",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                
                // Panggil Widget Submission yang sudah di-ekstrak
                SubmissionListWidget(submissions: submissions), 

                const SizedBox(height: 30),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 20),

                const Text(
                  "Pembagian Tugas",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                
                // Panggil Widget Task yang sudah di-ekstrak
                TaskListWidget(tasks: tasks),

              ],
            ),
          );
        },
      ),
    );
  }
}