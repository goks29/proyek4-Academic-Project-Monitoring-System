// lib/features/academic/lecturer/widgets/task_list_widget.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/task_allocation_model.dart';
import '../../../../services/remote/task_service.dart';

class TaskListWidget extends StatefulWidget {
  final List<TaskAllocationModel> tasks;
  // Callback untuk me-refresh halaman saat tugas dinilai
  final VoidCallback onTaskReviewed;

  const TaskListWidget({
    super.key, 
    required this.tasks,
    required this.onTaskReviewed,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  // Panggil service secara langsung untuk MVP
  final TaskService _taskService = TaskService(Supabase.instance.client);
  String? _loadingTaskId;

  Future<void> _handleReview(BuildContext context, TaskAllocationModel task, bool isApproved) async {
    final statusText = isApproved ? 'accepted' : 'rejected';
    final titleText = isApproved ? 'Terima Tugas Ini?' : 'Minta Revisi Tugas?';
    final buttonColor = isApproved ? Colors.green.shade600 : Colors.red.shade600;

    final TextEditingController feedbackController = TextEditingController();
    
    // Tampilkan catatan lama jika ada
    if (task.lecturerFeedback != null) {
      feedbackController.text = task.lecturerFeedback!;
    }

    final bool? confirmed = await showDialog<bool>(
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
              const Text("Berikan catatan untuk mahasiswa terkait tugas ini:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ketik catatan di sini...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: buttonColor)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _loadingTaskId = task.id);

      try {
        await _taskService.updateTaskApprovalStatus(
          task.id,
          statusText,
          feedback: feedbackController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Penilaian tugas tersimpan!"), backgroundColor: Colors.green),
          );
          widget.onTaskReviewed(); // Panggil callback refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _loadingTaskId = null);
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        text = "DITERIMA";
        break;
      case 'rejected':
      case 'revisi':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        text = "REVISI";
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        text = "MENUNGGU";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Text("Belum ada pembagian tugas.", style: TextStyle(color: Colors.grey.shade600));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        final isPending = task.status.toLowerCase() == 'pending';
        final isLoading = _loadingTaskId == task.id;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARIS 1: Deskripsi Tugas dan Badge Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.taskDescription,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  if (!isPending) _buildStatusBadge(task.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // BARIS 2: Status Dikerjakan & ID Mahasiswa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: task.isDone ? Colors.green.shade500 : Colors.grey.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.isDone ? "Sudah Dikerjakan" : "Belum Dikerjakan",
                        style: TextStyle(
                          color: task.isDone ? Colors.green.shade600 : Colors.grey.shade600,
                          fontWeight: task.isDone ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      "ID: ${task.studentId.substring(0, 5)}...",
                      style: TextStyle(color: Colors.indigo.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              // BARIS 3: Feedback Dosen (Muncul jika sudah dinilai)
              if (!isPending && task.lecturerFeedback != null && task.lecturerFeedback!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Catatan Anda:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text(task.lecturerFeedback!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
              ],

              // BARIS 4: Action Buttons (Muncul jika masih pending)
              if (isPending) ...[
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleReview(context, task, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600, side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                          ),
                          child: const Text("REVISI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleReview(context, task, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                          ),
                          child: const Text("TERIMA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}