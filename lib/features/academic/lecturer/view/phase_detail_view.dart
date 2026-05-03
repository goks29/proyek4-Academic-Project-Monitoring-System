// lib/features/academic/lecturer/view/phase_detail_view.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/progress_phase_model.dart';
import '../../../../models/workspace_model.dart';
import '../../../../models/task_allocation_model.dart';
import '../../../../models/submission_model.dart';

import '../../../../services/remote/task_service.dart';
import '../../../../services/remote/submission_service.dart';

// Import Component/Widgets yang sudah dipecah
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
    // 1. Ambil data tasks terlebih dahulu berdasarkan phase.id
    final tasks = await _taskService.getTasks(widget.phase.id);

    // 2. Ambil data submissions dari masing-masing task secara BERSAMAAN (Paralel)
    final submissionFutures = tasks.map((task) => _submissionService.getSubmissionsByTaskId(task.id));
    final submissionsList = await Future.wait(submissionFutures);
    
    // 3. Gabungkan list di dalam list menjadi satu list utuh (Flatten)
    final allSubmissions = submissionsList.expand((subs) => subs).toList();

    return {
      'tasks': tasks,
      'submissions': allSubmissions,
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
                
                // Panggil Widget Submission dengan callback refresh
                SubmissionListWidget(
                  submissions: submissions,
                  onSubmissionReviewed: () {
                    // Ketika dosen mensubmit nilai, halaman akan refresh otomatis
                    setState(() {
                      _phaseDataFuture = _fetchPhaseData();
                    });
                  },
                ), 

                const SizedBox(height: 30),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 20),

                const Text(
                  "Pembagian Tugas",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                
                // Panggil Widget Task
                TaskListWidget(tasks: tasks),
              ],
            ),
          );
        },
      ),
      // PERHATIKAN: Tidak ada lagi bottomNavigationBar di sini!
    );
  }
}