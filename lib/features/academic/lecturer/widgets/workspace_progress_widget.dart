// lib/features/academic/lecturer/widgets/workspace_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/progress_phase_model.dart';
import '../../../../controllers/lecturer/phase_approval_controller.dart';
import '../view/phase_detail_view.dart';
// Note: Kita butuh model Workspace dummy untuk dilempar ke layar detail
import '../../../../models/workspace_model.dart'; 

class WorkspaceProgressWidget extends StatelessWidget {
  final String workspaceId;
  final String teamName;

  const WorkspaceProgressWidget({
    super.key,
    required this.workspaceId,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    // ---> KUNCI PROVIDER: Pantau perubahan data Fase <---
    final phaseCtrl = context.watch<PhaseApprovalController>();

    if (phaseCtrl.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo));
    }

    final phases = phaseCtrl.phases;

    if (phases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text("Belum ada tahapan tugas.", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: phases.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildPhaseCard(context, phases[index]);
      },
    );
  }

  Widget _buildPhaseCard(BuildContext context, ProgressPhaseModel phase) {
    Color statusColor;
    IconData statusIcon;
    
    switch (phase.status.toLowerCase()) {
      case 'approved':
      case 'accepted':
      case 'selesai':
      case 'completed':
        statusColor = Colors.green.shade600;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
      case 'revisi':
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      case 'menunggu':
      case 'review':
        statusColor = Colors.orange.shade600;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      default:
        statusColor = Colors.grey.shade500;
        statusIcon = Icons.radio_button_unchecked;
    }

    return InkWell(
      onTap: () {
        // Buat model workspace sementara untuk lemparan ke halaman detail fase
        final dummyWorkspace = WorkspaceModel(
          id: workspaceId, teamName: teamName, status: 'pending', clientCreatedAt: DateTime.now()
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhaseDetailView(phase: phase, workspace: dummyWorkspace),
          ),
        ).then((_) {
            // Tarik ulang data fase jika kembali dari detail (barangkali dosen baru saja ACC fase)
            context.read<PhaseApprovalController>().fetchPhases(workspaceId);
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phase.phaseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text("Tahap ke-${phase.sortOrder}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    phase.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (phase.lecturerFeedback != null && phase.lecturerFeedback!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment_outlined, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text("Catatan Dosen:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(phase.lecturerFeedback!, style: TextStyle(fontSize: 13, color: Colors.blue.shade900)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}