import 'package:flutter/material.dart';
import 'workspace_create_view.dart';

class WorkspaceHomeView extends StatefulWidget {
  @override
  State<WorkspaceHomeView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),  
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Lingkaran transparan 
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text("Kelompok Tubes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 6),
                  const Text("Pilih salah satu opsi di bawah ini", style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // List Section
            _buildOptionCard(
              icon: Icons.add,
              title: "Buat Kelompok Baru",
              subtitle: "Jadilah ketua dan undang teman-temanmu bergabung.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkspaceCreateView(),
                  )
                );
              }
            ),
            
            const SizedBox(height: 16),
            
            _buildOptionCard(
              icon: Icons.login_rounded,
              title: "Gabung Kelompok",
              subtitle: "Masukkan ID kelompok yang dibagikan oleh ketuamu.",
              onTap: () {
                // buat nanti tombol join
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28.0),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.2)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.blueAccent, size: 28)
          ],
        ),
      ),
    );
  }
}