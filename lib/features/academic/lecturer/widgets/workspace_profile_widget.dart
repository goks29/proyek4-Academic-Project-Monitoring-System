// lib/features/academic/lecturer/widgets/workspace_profile_widget.dart
import 'package:flutter/material.dart';
import '../../../../models/workspace_model.dart';
import '../lecturer_controller.dart';

class WorkspaceProfileWidget extends StatelessWidget {
  final WorkspaceModel workspace;
  final LecturerController controller;

  const WorkspaceProfileWidget({super.key, required this.workspace, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPremiumHeader(),
        const SizedBox(height: 25),
        Row(
          children: [
            const Text("Anggota Tim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text("Daftar Lengkap", style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 15),
        _buildLuxuriousMembersList(),
      ],
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF1A237E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.group_work, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(child: Text(workspace.teamName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
            ],
          ),
          const SizedBox(height: 25),
          const Text("Topik Tugas Besar:", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(workspace.topicName.isNotEmpty ? workspace.topicName : "Topik belum ditentukan", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLuxuriousMembersList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getWorkspaceMembersDetails(workspace.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.indigo)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada anggota.")));

        final members = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isLeader = member['role'] == 'Ketua';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5))],
                border: Border.all(color: isLeader ? Colors.amber.withOpacity(0.5) : Colors.transparent, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: isLeader ? [Colors.amber.shade300, Colors.orange.shade500] : [Colors.indigo.shade300, Colors.indigo.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: (isLeader ? Colors.orange : Colors.indigo).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Center(child: Text(member['name'].isNotEmpty ? member['name'].substring(0, 1).toUpperCase() : "?", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(member['email'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: isLeader ? Colors.amber.withOpacity(0.15) : Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: isLeader ? Colors.amber.withOpacity(0.5) : Colors.grey[300]!)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLeader) ...[const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4)],
                        Text(member['role'], style: TextStyle(color: isLeader ? Colors.orange[800] : Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}