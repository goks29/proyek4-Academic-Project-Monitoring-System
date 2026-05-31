import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/project_model.dart';
import '../../../../controllers/lecturer/project_controller.dart';
import '../../../../controllers/lecturer/topic_approval_controller.dart';
import '../../../../controllers/lecturer/progress_dashboard_controller.dart';

import '../widgets/lecturer_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/project_list_widget.dart';
import '../widgets/workspace_list_widget.dart';
import '../widgets/lecturer_bottom_nav.dart';
import '../widgets/project_input_field.dart';
import 'workspace_detail_view.dart';

class LecturerView extends StatefulWidget {
  const LecturerView({super.key});
  @override
  State<LecturerView> createState() => _LecturerViewState();
}

class _LecturerViewState extends State<LecturerView> {
  ProjectModel? _selectedProject;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectController>().fetchProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBackNavigation() {
    setState(() => _selectedProject = null);
  }

  void _showEditProjectDialog(ProjectController projectCtrl) {
    final titleCtrl = TextEditingController(text: _selectedProject!.title);
    final descCtrl = TextEditingController(text: _selectedProject!.description);
    final infoCtrl = TextEditingController(text: _selectedProject!.finalSubmissionInfo ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text("Edit Proyek", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProjectInputField(label: "JUDUL TUGAS", hint: "", controller: titleCtrl),
              const SizedBox(height: 16),
              ProjectInputField(label: "DESKRIPSI TUGAS", hint: "", controller: descCtrl, maxLines: 3),
              const SizedBox(height: 16),
              ProjectInputField(label: "INFO PENGUMPULAN", hint: "", controller: infoCtrl, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, elevation: 0),
            onPressed: () async {
              await projectCtrl.updateProject(
                _selectedProject!.joinCode,
                title: titleCtrl.text,
                description: descCtrl.text,
                submissionInfo: infoCtrl.text,
              );
              if (mounted) {
                setState(() {
                  _selectedProject = projectCtrl.projects.firstWhere((p) => p.joinCode == _selectedProject!.joinCode);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data diperbarui!"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Simpan"),
          )
        ],
      )
    );
  }

  void _confirmCloseProject(ProjectController projectCtrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Tutup Proyek?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Proyek yang ditutup akan ditandai selesai. Lanjutkan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, elevation: 0),
            onPressed: () async {
              await projectCtrl.closeProject(_selectedProject!.joinCode);
              if (mounted) {
                setState(() => _selectedProject = null); 
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proyek ditutup!"), backgroundColor: Colors.orange));
              }
            },
            child: const Text("Tutup Proyek"),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectCtrl = context.watch<ProjectController>(); 

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: _selectedProject == null
          ? LecturerBottomNav(onRefresh: () => setState(() {}))
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              LecturerHeader(selectedProject: _selectedProject, selectedWorkspace: null, onBackPressed: _handleBackNavigation),
              const SizedBox(height: 25),
              
              if (_selectedProject != null) ...[
                if (_selectedProject!.isActive) 
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 14), label: const Text("Edit Proyek", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _showEditProjectDialog(projectCtrl),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo, side: BorderSide(color: Colors.indigo.shade200), padding: const EdgeInsets.symmetric(horizontal: 12)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.power_settings_new, size: 14), label: const Text("Tutup Proyek", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _confirmCloseProject(projectCtrl),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade600, side: BorderSide(color: Colors.red.shade200), padding: const EdgeInsets.symmetric(horizontal: 12)),
                        ),
                      ],
                    ),
                  ),
                WorkspaceListWidget(
                  onWorkspaceSelected: (ws) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkspaceDetailView(
                          workspace: ws,
                          isProjectClosed: !_selectedProject!.isActive,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
              ] else ...[
                SearchBarWidget(controller: _searchController, onChanged: (val) => setState(() => _searchQuery = val.toLowerCase())),
                const SizedBox(height: 25),
                DashboardStats(activeProjects: projectCtrl.onProgressProjectCount, pendingReviews: 5),
                const SizedBox(height: 30),
                const Text("Daftar Tugas Besar Mahasiswa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                ProjectListWidget(
                  projects: projectCtrl.projects, isLoading: projectCtrl.isLoading, searchQuery: _searchQuery,
                  onProjectSelected: (project) {
                    setState(() => _selectedProject = project);
                    // Panggil data dari Provider
                    context.read<TopicApprovalController>().fetchWorkspacesByProject(project.joinCode);
                    context.read<ProgressDashboardController>().fetchGroupProgress(project.joinCode);
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}