// lib/features/academic/lecturer/widgets/workspace_list_widget.dart
import 'package:flutter/material.dart';
import '../../../../models/workspace_model.dart';
import '../lecturer_controller.dart';

class WorkspaceListWidget extends StatelessWidget {
  final Future<List<WorkspaceModel>> workspacesFuture;
  final LecturerController controller;
  final Function(WorkspaceModel) onWorkspaceSelected;

  const WorkspaceListWidget({
    super.key,
    required this.workspacesFuture,
    required this.controller,
    required this.onWorkspaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkspaceModel>>(
      future: workspacesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("Belum ada kelompok."));
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, i) {
            final ws = snapshot.data![i];
            
            return GestureDetector(
              onTap: () => onWorkspaceSelected(ws),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20), 
                  border: Border.all(color: Colors.grey[200]!)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ws.teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      (ws.topicName?.isNotEmpty ?? false) ? "Topik: ${ws.topicName}" : "Topik belum ditentukan",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    
                    // ---> INI BAGIAN YANG DIUBAH (FUTURE BUILDER UNTUK PROGRESS) <---
                    FutureBuilder<double>(
                      future: controller.getRealWorkspaceProgress(ws.id),
                      builder: (context, progressSnapshot) {
                        // Jika masih loading, kasih animasi loading tipis
                        if (progressSnapshot.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator(backgroundColor: Colors.transparent, minHeight: 2);
                        }
                        
                        final progress = progressSnapshot.data ?? 0.0;
                        
                        return Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress, 
                                backgroundColor: Colors.grey[200], 
                                color: progress == 1.0 ? Colors.green : Colors.indigo, // Hijau kalau 100%
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(10),
                              )
                            ),
                            const SizedBox(width: 12),
                            Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      }
                    ),
                    // ---------------------------------------------------------------
                    
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}