// lib/features/academic/lecturer/view/lecturer_view.dart
import 'package:flutter/material.dart';
import '../../../../models/project_model.dart';
import '../lecturer_controller.dart';

// IMPORT WIDGETS & VIEWS
import '../widgets/lecturer_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/project_list_widget.dart';
import '../widgets/workspace_list_widget.dart';
import '../widgets/lecturer_bottom_nav.dart';
import '../widgets/project_input_field.dart'; // Dibutuhkan untuk dialog Edit Proyek
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
    // Ambil daftar semua proyek secara asynchronous
    final projects = await _controller.getAllProjects();
    
    // Hitung berapa proyek yang statusnya masih aktif (on progress)
    final activeCount = projects.where((p) => p.isActive).length;

    // Kembalikan datanya (pendingReviews biarkan dummy dulu tidak apa-apa)
    return {
      'activeProjects': activeCount, 
      'pendingReviews': 5
    };
  }
  void _handleBackNavigation() {
    setState(() {
      _selectedProject = null;
    });
  }

  // ==========================================
  // FUNGSI MANAJEMEN PROYEK (EDIT)
  // ==========================================
  void _showEditProjectDialog() {
    final titleCtrl = TextEditingController(text: _selectedProject!.title);
    final descCtrl = TextEditingController(text: _selectedProject!.description);
    final infoCtrl = TextEditingController(text: _selectedProject!.finalSubmissionInfo ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
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
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx), 
                child: const Text("Batal", style: TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, elevation: 0),
                onPressed: isSaving ? null : () async {
                  setStateDialog(() => isSaving = true);
                  
                  final success = await _controller.updateProject(
                    _selectedProject!.joinCode,
                    title: titleCtrl.text,
                    description: descCtrl.text,
                    submissionInfo: infoCtrl.text,
                  );
                  
                  if (success) {
                    setState(() {
                      // Update state lokal agar layar langsung berubah tanpa loading ulang
                      _selectedProject = ProjectModel(
                        joinCode: _selectedProject!.joinCode,
                        lecturerId: _selectedProject!.lecturerId,
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        finalSubmissionInfo: infoCtrl.text,
                        isActive: _selectedProject!.isActive,
                        createdAt: _selectedProject!.createdAt,
                      );
                    });
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Data proyek diperbarui!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)
                      );
                    }
                  } else {
                    setStateDialog(() => isSaving = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gagal memperbarui proyek.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red)
                      );
                    }
                  }
                },
                child: isSaving 
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Simpan"),
              )
            ],
          );
        }
      )
    );
  }

  // ==========================================
  // FUNGSI MANAJEMEN PROYEK (TUTUP)
  // ==========================================
  void _confirmCloseProject() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Tutup Proyek?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Proyek yang ditutup akan ditandai selesai dan mahasiswa tidak bisa lagi mengumpulkan tugas. Lanjutkan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, elevation: 0),
            onPressed: () async {
              final success = await _controller.closeProject(_selectedProject!.joinCode);
              if (success) {
                setState(() => _selectedProject = null); // Lempar kembali ke beranda
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Proyek telah ditutup!"), backgroundColor: Colors.orange)
                  );
                }
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
                controller: _controller, 
              ),
              const SizedBox(height: 25),
              
              // 2. Logika Navigasi
              if (_selectedProject != null) ...[
                
                // ---> TOMBOL AKSI PROYEK (EDIT & TUTUP) <---
                if (_selectedProject!.isActive) 
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: const Text("Edit Proyek", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: _showEditProjectDialog,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo, 
                            side: BorderSide(color: Colors.indigo.shade200), 
                            padding: const EdgeInsets.symmetric(horizontal: 12)
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.power_settings_new, size: 14),
                          label: const Text("Tutup Proyek", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: _confirmCloseProject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600, 
                            side: BorderSide(color: Colors.red.shade200), 
                            padding: const EdgeInsets.symmetric(horizontal: 12)
                          ),
                        ),
                      ],
                    ),
                  ),

                // Daftar Kelompok di dalam Proyek
                WorkspaceListWidget(
                  workspacesFuture: _controller.getWorkspacesByJoinCode(_selectedProject!.joinCode),
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
                    ).then((_) {
                      // Refresh halaman jika kembali dari WorkspaceDetailView (misal habis ACC topik)
                      setState(() {});
                    });
                  },
                ),
              ] 
              else ...[
                // Halaman Depan (Beranda)
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