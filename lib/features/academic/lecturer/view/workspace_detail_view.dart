// lib/features/academic/lecturer/view/workspace_detail_view.dart
import 'package:flutter/material.dart';
import '../../../../models/workspace_model.dart';
import '../lecturer_controller.dart';

// IMPORT WIDGETS
import '../widgets/workspace_widget.dart';
import '../widgets/workspace_progress_widget.dart'; // File baru yang akan kita buat

class WorkspaceDetailView extends StatelessWidget {
  final WorkspaceModel workspace;
  final LecturerController controller;

  const WorkspaceDetailView({
    super.key,
    required this.workspace,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Menentukan ada 2 Tab
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Detail Kelompok",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            // Header tetap nangkring di atas
            WorkspaceHeaderWidget(workspace: workspace),
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
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: "Progress Tugas"), // Tab 1 (Default muncul pertama)
                  Tab(text: "Anggota Tim"), // Tab 2
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Isi dari masing-masing Tab
            Expanded(
              child: TabBarView(
                children: [
                  // Konten Tab 1: Daftar Task / Phase
                  WorkspaceProgressWidget(
                    workspace: workspace,
                    controller: controller,
                  ),

                  // Konten Tab 2: Daftar Anggota (Dibungkus scroll agar shrinkWrap bekerja aman)
                  SingleChildScrollView(
                    child: WorkspaceMembersWidget(
                      workspace: workspace,
                      controller: controller,
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
