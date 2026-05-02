// lib/features/academic/lecturer/widgets/task_list_widget.dart
import 'package:flutter/material.dart';
import '../../../../models/task_allocation_model.dart';

class TaskListWidget extends StatelessWidget {
  final List<TaskAllocationModel> tasks;

  const TaskListWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Text("Belum ada pembagian tugas.", style: TextStyle(color: Colors.grey.shade600));
    }

    return ListView.separated(
      shrinkWrap: true, // WAJIB ada kalau di dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.taskDescription,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                        color: task.isDone ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.isDone ? "Selesai" : "Dikerjakan",
                        style: TextStyle(
                          color: task.isDone ? Colors.green : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "ID: ${task.studentId.substring(0, 5)}...",
                    style: const TextStyle(color: Colors.indigo, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}