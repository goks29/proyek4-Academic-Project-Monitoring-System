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
import '../../../../services/remote/phase_service.dart';

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
  final PhaseService _phaseService = PhaseService(Supabase.instance.client);
  
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phaseDataFuture = _fetchPhaseData();
    
    // Isi default catatan jika sebelumnya sudah ada feedback dari dosen
    if (widget.phase.lecturerFeedback != null) {
      _feedbackController.text = widget.phase.lecturerFeedback!;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchPhaseData() async {
    // 1. Ambil data tasks 
    final tasks = await _taskService.getTasks(widget.phase.id);

    // 2. Ambil data submissions 
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
                
                // Panggil Widget Submission
                SubmissionListWidget(submissions: submissions), 

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
      // Action Bar di bagian bawah untuk validasi dosen
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  // ==========================================
  // WIDGET UI: BOTTOM ACTION BAR (MVP FITUR DOSEN)
  // ==========================================
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // TOMBOL REVISI (Tolak)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showApprovalDialog(context, isApproved: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade600),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("REVISI", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            // TOMBOL TERIMA (Lulus)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showApprovalDialog(context, isApproved: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("TERIMA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FUNGSI UX: MUNCULKAN DIALOG CATATAN
  // ==========================================
  void _showApprovalDialog(BuildContext context, {required bool isApproved}) {
    final statusText = isApproved ? 'approved' : 'revisi';
    final titleText = isApproved ? 'Terima Tahapan Ini?' : 'Minta Revisi?';
    final buttonColor = isApproved ? Colors.green.shade600 : Colors.red.shade600;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Berikan catatan/feedback untuk kelompok ini:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Ketik catatan di sini...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: buttonColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus(); // Tutup keyboard
                Navigator.pop(context); // Tutup dialog
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Menyimpan status..."), duration: Duration(seconds: 1)),
                );

                try {
                  await _phaseService.updatePhaseStatus(
                    widget.phase.id, 
                    {
                      'status': statusText,
                      'lecturer_feedback': _feedbackController.text,
                    }
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Status berhasil diperbarui!"), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context, true); // Pop out ke halaman sebelumnya
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text("Simpan & Kirim"),
            ),
          ],
        );
      },
    );
  }
}