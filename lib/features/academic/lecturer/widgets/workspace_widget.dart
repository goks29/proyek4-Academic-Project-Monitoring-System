// lib/features/academic/lecturer/widgets/workspace_widget.dart
import 'package:flutter/material.dart';
import '../../../../models/workspace_model.dart';
import '../lecturer_controller.dart';

// ==========================================
// WIDGET UNTUK HEADER (Desain Sangat Simpel & Bersih)
// ==========================================
class WorkspaceHeaderWidget extends StatelessWidget {
  final WorkspaceModel workspace;

  const WorkspaceHeaderWidget({super.key, required this.workspace});

  @override
  Widget build(BuildContext context) {
    final bool hasTopic = workspace.topicName.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workspace.teamName,
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Topik Tugas Besar:", 
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)
          ),
          const SizedBox(height: 4),
          Text(
            hasTopic ? workspace.topicName : "Topik belum ditentukan",
            style: TextStyle(
              fontSize: 16,
              color: hasTopic ? Colors.black87 : Colors.grey.shade400,
              fontStyle: hasTopic ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET LIST ANGGOTA (Menggunakan ListTile yang Minimalis)
// ==========================================
class WorkspaceMembersWidget extends StatelessWidget {
  final WorkspaceModel workspace;
  final LecturerController controller;

  const WorkspaceMembersWidget({
    super.key, 
    required this.workspace, 
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getWorkspaceMembersDetails(workspace.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Belum ada anggota terdaftar.", style: TextStyle(color: Colors.grey.shade500)),
            )
          );
        }
        
        final members = snapshot.data!;
        
        return ListView.separated(
          // ---> INI KUNCI AGAR DATA MUNCUL DI LAYAR <---
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          // ---------------------------------------------
          
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: members.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            final isLeader = member['role'] == 'Ketua';
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              leading: CircleAvatar(
                backgroundColor: isLeader ? Colors.amber.shade100 : Colors.indigo.shade50,
                child: Text(
                  member['name'].isNotEmpty ? member['name'].substring(0, 1).toUpperCase() : "?",
                  style: TextStyle(
                    color: isLeader ? Colors.amber.shade900 : Colors.indigo.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member['name'], 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
              ),
              subtitle: Text(
                member['email'], 
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)
              ),
              trailing: isLeader 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text("Ketua", style: TextStyle(color: Colors.amber.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                : null, // Anggota biasa tidak perlu label agar lebih bersih
            );
          },
        );
      },
    );
  }
}