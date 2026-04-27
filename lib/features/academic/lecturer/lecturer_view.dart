import 'package:flutter/material.dart';
import 'lecturer_controller.dart';
import '../../../models/project_model.dart';
import '../../../models/workspace_model.dart';
import 'add_project_view.dart';
import 'workspace_detail_view.dart';

class LecturerView extends StatefulWidget {
  const LecturerView({super.key});

  @override
  State<LecturerView> createState() => _LecturerViewState();
}

class _LecturerViewState extends State<LecturerView> {
  final LecturerController _controller = LecturerController();
  ProjectModel? _selectedProject; // Untuk melacak proyek yang sedang dibuka

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // FOOTER: Bottom Navigation Bar (Hanya muncul di halaman utama)
      // lib/features/academic/lecturer/lecturer_view.dart

bottomNavigationBar: _selectedProject == null ? BottomNavigationBar(
  currentIndex: 0,
  selectedItemColor: Colors.indigo,
  unselectedItemColor: Colors.grey,
  onTap: (index) async {
    if (index == 1) { // Index 1 adalah tombol 'TAMBAH'
      // Berpindah ke halaman form tambah proyek
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddProjectView(),
        ),
      );

      // Jika form berhasil disimpan (mengembalikan true), refresh data
      if (result == true) {
        setState(() {
          // Trigger refresh FutureBuilder
        });
      }
    }
    // Tambahkan logika index 0 atau 2 jika diperlukan nanti
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'BERANDA'),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'TAMBAH'),
    BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'MAHASISWA'),
  ],
) : null,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // HEADER & BACK BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_selectedProject != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => setState(() => _selectedProject = null),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedProject == null ? "Halo, Pak Arnold" : "Detail Proyek",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedProject == null ? "Dosen Pengampu JTK" : _selectedProject!.title,
                        style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.indigo,
                    child: Text("AB", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // SWITCHER: Tampilkan List Proyek atau List Kelompok
              _selectedProject == null 
                ? _buildDashboardHome() 
                : _buildWorkspaceList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGET 1: TAMPILAN BERANDA UTAMA ---
  Widget _buildDashboardHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SEARCH BAR
        _buildSearchBar(),
        const SizedBox(height: 25),
        // STATISTIK
        _buildStatCards(),
        const SizedBox(height: 30),
        const Text("Daftar Tugas Besar Mahasiswa", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        // LIST PROJECT DARI DATABASE
        FutureBuilder<List<ProjectModel>>(
          future: _controller.getAllProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada proyek."));

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final project = snapshot.data![index];
                return _buildProjectCard(project);
              },
            );
          },
        ),
      ],
    );
  }

  // --- SUB-WIDGET 2: DAFTAR KELOMPOK (LEVEL 2) ---
  Widget _buildWorkspaceList() {
    return FutureBuilder<List<WorkspaceModel>>(
      future: _controller.getWorkspacesByProject(_selectedProject!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada kelompok bergabung."));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final workspace = snapshot.data![index];
            double progress = _controller.calculateProgress(workspace);
            return _buildGroupProgressCard(workspace, progress);
          },
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: const TextField(
        decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.grey), hintText: "Cari Kelompok...", border: InputBorder.none),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _statCard("TUGAS BESAR AKTIF", "14", Colors.indigoAccent[700]!, Colors.white),
        const SizedBox(width: 15),
        _statCard("BUTUH REVIEW", "5", Colors.white, Colors.orange, isBordered: true),
      ],
    );
  }

  Widget _statCard(String label, String value, Color bg, Color valColor, {bool isBordered = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: isBordered ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: isBordered ? Colors.grey[600] : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: valColor, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return GestureDetector(
      onTap: () => setState(() => _selectedProject = project),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statusBadge("On Progress", Colors.red[50]!, Colors.red[400]!),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Text(project.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(project.joinCode, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupProgressCard(WorkspaceModel workspace, double progress) {
    return GestureDetector( // <-- TAMBAHKAN INI
      onTap: () {
        // Navigasi ke halaman detail kelompok saat kartu diklik
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailView(
              workspace: workspace, 
              controller: _controller, // Lempar controller agar view tetap bodoh
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workspace.teamName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            // Tambahkan teks Topik di bawah nama tim agar lebih informatif
            Text(
              workspace.topicName.isNotEmpty ? "Topik: ${workspace.topicName}" : "Topik belum ditentukan",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    color: Colors.indigo,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ); //
  }


  Widget _statusBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10)),
    );
  }

  
}
