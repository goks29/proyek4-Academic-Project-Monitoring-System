// lib/features/academic/lecturer/view/lecturer_view.dart
import 'package:flutter/material.dart';
import '../../../../models/project_model.dart';
// import '../../../../models/workspace_model.dart';
import '../lecturer_controller.dart';

// IMPORT WIDGETS & VIEWS
import '../widgets/lecturer_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/project_list_widget.dart';
import '../widgets/workspace_list_widget.dart';
import '../widgets/lecturer_bottom_nav.dart';
import 'workspace_detail_view.dart';
import '../../../../main.dart';

class LecturerView extends StatefulWidget {
  const LecturerView({super.key});

  @override
  State<LecturerView> createState() => _LecturerViewState();
}

class _LecturerViewState extends State<LecturerView> {
  final LecturerController _controller = globalLecturerController;
  ProjectModel? _selectedProject;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, int>> _getMockStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'activeProjects': 14, 'pendingReviews': 5};
  }

  void _handleBackNavigation() {
    setState(() {
      _selectedProject = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      bottomNavigationBar: _selectedProject == null
          ? LecturerBottomNav(controller: _controller, onRefresh: () => setState(() {}))
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 1. Header Global
              LecturerHeader(
                selectedProject: _selectedProject,
                selectedWorkspace: null,
                onBackPressed: _handleBackNavigation,
              ),
              const SizedBox(height: 25),
              
              // 2. Logika Navigasi (Tinggal 2 Level: Beranda -> List Kelompok)
              if (_selectedProject != null) ...[
                WorkspaceListWidget(
                  workspacesFuture: _controller.getWorkspacesByProject(_selectedProject!.id),
                  controller: _controller,
                  onWorkspaceSelected: (ws) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkspaceDetailView(
                          workspace: ws,
                          controller: _controller,
                        ),
                      ),
                    );
                  },
                ),
              ] 
              else ...[
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase())
                ),
                const SizedBox(height: 25),
                
                DashboardStats(statsFuture: _getMockStats()),
                const SizedBox(height: 30),
                
                const Text("Daftar Tugas Besar Mahasiswa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                ProjectListWidget(
                  projectsFuture: _controller.getAllProjects(),
                  searchQuery: _searchQuery,
                  onProjectSelected: (project) => setState(() => _selectedProject = project),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}