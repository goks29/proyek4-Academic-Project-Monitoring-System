import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/workspace_model.dart';
import '../../../../controllers/lecturer/topic_approval_controller.dart';
import '../../../../controllers/lecturer/progress_dashboard_controller.dart';

class WorkspaceListWidget extends StatelessWidget {
  final Function(WorkspaceModel) onWorkspaceSelected;

  const WorkspaceListWidget({super.key, required this.onWorkspaceSelected});

  @override
  Widget build(BuildContext context) {
    final topicCtrl = context.watch<TopicApprovalController>();
    final progressCtrl = context.watch<ProgressDashboardController>();

    if (topicCtrl.isLoading || progressCtrl.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    if (topicCtrl.workspaces.isEmpty) return const Center(child: Text("Belum ada kelompok."));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topicCtrl.workspaces.length,
      itemBuilder: (context, i) {
        final ws = topicCtrl.workspaces[i];
        
        // Cari progress kelompok dari Provider
        double progress = 0.0;
        try {
          final groupProgress = progressCtrl.groupProgressList.firstWhere((g) => g.workspaceId == ws.id);
          progress = groupProgress.progressPercent / 100.0; // Konversi % ke desimal 0-1
        } catch (_) {}

        return GestureDetector(
          onTap: () => onWorkspaceSelected(ws),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ws.teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text((ws.topicName?.isNotEmpty ?? false) ? "Topik: ${ws.topicName}" : "Topik belum ditentukan", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        color: progress == 1.0 ? Colors.green : Colors.indigo,
                        minHeight: 8, borderRadius: BorderRadius.circular(10),
                      )
                    ),
                    const SizedBox(width: 12),
                    Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}