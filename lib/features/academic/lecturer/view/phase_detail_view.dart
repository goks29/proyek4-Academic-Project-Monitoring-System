// lib/features/academic/lecturer/view/phase_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/progress_phase_model.dart';
import '../../../../models/workspace_model.dart';
import '../../../../models/task_allocation_model.dart';
import '../../../../models/submission_model.dart';

// --- IMPORT REPOSITORY & CONTROLLER ---
import '../../../../repositories/task_repository.dart';
import '../../../../repositories/submission_repository.dart';
import '../../../../controllers/lecturer/phase_approval_controller.dart';

import '../widgets/submission_list_widget.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/phase_comment_widget.dart';

class PhaseDetailView extends StatefulWidget {
  final ProgressPhaseModel phase;
  final WorkspaceModel workspace;
  final bool isProjectClosed;

  const PhaseDetailView({
    super.key,
    required this.phase,
    required this.workspace,
    this.isProjectClosed = false,
  });

  @override
  State<PhaseDetailView> createState() => _PhaseDetailViewState();
}

class _PhaseDetailViewState extends State<PhaseDetailView> {
  late Future<Map<String, dynamic>> _phaseDataFuture;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phaseDataFuture = _fetchPhaseData();
    
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
    final taskRepo = context.read<TaskRepository>();
    final subRepo = context.read<SubmissionRepository>();

    final tasks = await taskRepo.getTasks(widget.phase.id);
    final submissionFutures = tasks.map((task) => subRepo.getSubmissionsByTaskId(task.id));
    final submissionsList = await Future.wait(submissionFutures);
    
    final allSubmissions = submissionsList.expand((subs) => subs).toList();

    return {
      'tasks': tasks,
      'submissions': allSubmissions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosed = widget.workspace.isCompleted || widget.isProjectClosed;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Detail ${widget.phase.phaseName}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.workspace.teamName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _phaseDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          if (snapshot.hasError) return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          
          final tasks = snapshot.data!['tasks'] as List<TaskAllocationModel>;
          final submissions = snapshot.data!['submissions'] as List<SubmissionModel>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hasil Kerja Mahasiswa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                
                SubmissionListWidget(
                  submissions: submissions,
                  isReadOnly: isClosed, // ---> TERAPKAN READ-ONLY
                  onSubmissionReviewed: () => setState(() => _phaseDataFuture = _fetchPhaseData()),
                ),

                const SizedBox(height: 30),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 20),

                const Text("Pembagian Tugas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                
                TaskListWidget(
                  tasks: tasks,
                  isReadOnly: isClosed, // ---> TERAPKAN READ-ONLY
                  onTaskReviewed: () => setState(() => _phaseDataFuture = _fetchPhaseData()),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
            builder: (context) => PhaseCommentWidget(
              phase: widget.phase,
              isReadOnly: isClosed, // ---> TERAPKAN READ-ONLY
            ),
          );
        },
        icon: const Icon(Icons.forum_outlined), label: const Text("Diskusi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo, foregroundColor: Colors.white, elevation: 4,
      ),
      
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: _phaseDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final submissions = snapshot.data!['submissions'] as List<SubmissionModel>;
          
          final hasSubmissions = submissions.isNotEmpty;
          final hasPendingSubmissions = submissions.any((sub) => sub.status.toLowerCase() == 'pending');
          final isPhaseReviewed = widget.phase.status.toLowerCase() != 'pending';

          return _buildBottomActionBar(context, hasPendingSubmissions, isPhaseReviewed, hasSubmissions);
        }
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, bool hasPendingSubmissions, bool isPhaseReviewed, bool hasSubmissions) {
    final bool isClosed = widget.workspace.isCompleted || widget.isProjectClosed;
    if (isClosed) {
      return Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: Colors.grey.shade600), const SizedBox(width: 8),
              Expanded(child: Text("Proyek ditutup. Akses modifikasi dikunci.", style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      );
    }
    
    if (isPhaseReviewed) {
      return Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green.shade600), const SizedBox(width: 8),
              Expanded(child: Text("Fase ini telah ditutup dan dinilai (${widget.phase.status.toUpperCase()}).", style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      );
    }
    
    if (!hasSubmissions) {
      return Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
        child: SafeArea(
          child: Row(
            children: [
              Icon(Icons.hourglass_empty_rounded, size: 18, color: Colors.grey.shade500), const SizedBox(width: 8),
              Expanded(child: Text("Menunggu mahasiswa mengumpulkan hasil kerja...", style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic))),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            if (hasPendingSubmissions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700), const SizedBox(width: 8), Expanded(child: Text("Selesaikan penilaian semua pengumpulan terlebih dahulu.", style: TextStyle(color: Colors.orange.shade700, fontSize: 12)))]),
              ),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: hasPendingSubmissions ? null : () => _showApprovalDialog(context, isApproved: false), style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade600, disabledForegroundColor: Colors.grey.shade400, side: BorderSide(color: hasPendingSubmissions ? Colors.grey.shade300 : Colors.red.shade600), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("REVISI FASE", style: TextStyle(fontWeight: FontWeight.bold)))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton(onPressed: hasPendingSubmissions ? null : () => _showApprovalDialog(context, isApproved: true), style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, disabledBackgroundColor: Colors.grey.shade200, foregroundColor: Colors.white, disabledForegroundColor: Colors.grey.shade500, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("TERIMA FASE", style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, {required bool isApproved}) {
    final statusText = isApproved ? 'accepted' : 'rejected';
    final titleText = isApproved ? 'Terima Fase Ini?' : 'Minta Revisi Fase?';
    final buttonColor = isApproved ? Colors.green.shade600 : Colors.red.shade600;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Berikan catatan/feedback untuk kelompok pada fase ini:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: _feedbackController, maxLines: 4,
                decoration: InputDecoration(hintText: "Ketik catatan di sini...", filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: buttonColor))),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus(); 
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menyimpan status fase..."), duration: Duration(seconds: 1)));
                
                try {
                  await context.read<PhaseApprovalController>().approvePhase(
                    widget.phase.id,
                    statusText,
                    _feedbackController.text
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status Fase diperbarui!"), backgroundColor: Colors.green));
                    Navigator.pop(context, true); 
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white, elevation: 0), child: const Text("Simpan & Kirim"),
            ),
          ],
        );
      },
    );
  }
}