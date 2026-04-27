// lib/features/academic/lecturer/workspace_detail_view.dart
import 'package:flutter/material.dart';
import '../../../models/workspace_model.dart';
import '../../../models/progress_phase_model.dart';
import 'lecturer_controller.dart';

class WorkspaceDetailView extends StatelessWidget {
  final WorkspaceModel workspace;
  final LecturerController controller;

  const WorkspaceDetailView({
    super.key, 
    required this.workspace, 
    required this.controller
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(workspace.teamName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(workspace.topicName.isNotEmpty ? workspace.topicName : "Belum ada topik", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(text: "Anggota Tim"),
              Tab(text: "Progress Kerja"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMembersTab(),
            _buildProgressTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: ANGGOTA TIM ---
  Widget _buildMembersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getWorkspaceMembersDetails(workspace.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada anggota di kelompok ini."));

        final members = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isLeader = member['role'] == 'Ketua';

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isLeader ? Colors.indigo[100]! : Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isLeader ? Colors.indigo : Colors.grey[200],
                    child: Icon(Icons.person, color: isLeader ? Colors.white : Colors.grey[600]),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(member['email'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLeader ? Colors.indigo[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(member['role'], style: TextStyle(color: isLeader ? Colors.indigo : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: PROGRESS KERJA ---
  Widget _buildProgressTab() {
    return FutureBuilder<List<ProgressPhaseModel>>(
      future: controller.getWorkspacePhases(workspace.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada fase pengerjaan (Progress)."));

        final phases = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: phases.length,
          itemBuilder: (context, index) {
            final phase = phases[index];
            
            // Penentuan warna berdasarkan status
            Color statusColor = Colors.grey;
            if (phase.status == 'approved') statusColor = Colors.green;
            if (phase.status == 'pending') statusColor = Colors.orange;
            if (phase.status == 'revision') statusColor = Colors.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fase ${phase.sortOrder}", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                      Icon(Icons.assignment, color: Colors.grey[400], size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(phase.phaseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(phase.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      Text("Lihat Detail Tugas >", style: TextStyle(color: Colors.indigo[400], fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  
}