// lib/features/academic/lecturer/view/workspace_detail_view.dart
import 'package:flutter/material.dart';
import '../../../../models/workspace_model.dart';
import '../lecturer_controller.dart';

// IMPORT WIDGETS
import '../widgets/workspace_widget.dart';
import '../widgets/workspace_progress_widget.dart';

class WorkspaceDetailView extends StatefulWidget {
  final WorkspaceModel workspace;
  final LecturerController controller;

  const WorkspaceDetailView({
    super.key,
    required this.workspace,
    required this.controller,
  });

  @override
  State<WorkspaceDetailView> createState() => _WorkspaceDetailViewState();
}

class _WorkspaceDetailViewState extends State<WorkspaceDetailView> {
  // Simpan data workspace ke state agar bisa diperbarui (refresh)
  late WorkspaceModel _currentWorkspace;

  @override
  void initState() {
    super.initState();
    _currentWorkspace = widget.workspace;
  }

  // Fungsi untuk menarik ulang data workspace spesifik dari database jika topik di-ACC
  Future<void> _refreshWorkspaceData() async {
    final workspaces = await widget.controller.getWorkspacesByJoinCode(_currentWorkspace.joinCode ?? '');
    final updatedWorkspace = workspaces.firstWhere((w) => w.id == _currentWorkspace.id);
    setState(() {
      _currentWorkspace = updatedWorkspace;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Detail Kelompok",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context, true), // Kirim sinyal refresh ke beranda saat back
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header yang sekarang bisa dipakai untuk validasi topik!
            WorkspaceHeaderWidget(
              workspace: _currentWorkspace, // Pakai data dari state
              controller: widget.controller,
              onTopicReviewed: () {
                // Panggil fungsi refresh saat dosen selesai menilai topik
                _refreshWorkspaceData();
              },
            ),
            
            const SizedBox(height: 20),
            
            // Tab Bar (Tombol Navigasi)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.indigo.shade700,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "Progress Tugas"), 
                  Tab(text: "Anggota Tim"), 
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Isi dari masing-masing Tab
            Expanded(
              child: TabBarView(
                children: [
                  WorkspaceProgressWidget(
                    workspace: _currentWorkspace,
                    controller: widget.controller,
                  ),
                  SingleChildScrollView(
                    child: WorkspaceMembersWidget(
                      workspace: _currentWorkspace,
                      controller: widget.controller,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}