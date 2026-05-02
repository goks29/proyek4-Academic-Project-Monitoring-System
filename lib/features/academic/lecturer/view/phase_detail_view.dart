// lib/features/academic/lecturer/view/phase_detail_view.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/progress_phase_model.dart';
import '../../../../models/workspace_model.dart';
import '../../../../models/task_allocation_model.dart';

// Import Controller
import '../../../../services/remote/task_service.dart';

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
  // Kita inisialisasi pemanggilan data Supabase secara langsung terlebih dahulu
  // untuk memastikan alur UX berjalan sempurna.
  late Future<List<TaskAllocationModel>> _tasksFuture;
  final TaskService _taskService = TaskService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    // Tarik data tugas berdasarkan ID fase ini
    _tasksFuture = _taskService.getTasks(widget.phase.id);
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
      body: FutureBuilder<List<TaskAllocationModel>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada pembagian tugas di fase ini."),
            );
          }

          final tasks = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deskripsi Tugas
                    Text(
                      task.taskDescription,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Info Status & PIC
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status (Done / Progress)
                        Row(
                          children: [
                            Icon(
                              task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                              color: task.isDone ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              task.isDone ? "Selesai" : "Dikerjakan",
                              style: TextStyle(
                                color: task.isDone ? Colors.green : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // ID Mahasiswa (Nanti kita convert jadi Nama)
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Colors.indigo),
                            const SizedBox(width: 4),
                            Text(
                              "ID: ${task.studentId.substring(0, 5)}...", // Dipotong biar rapi sementara
                              style: const TextStyle(color: Colors.indigo, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}