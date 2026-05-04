// lib/features/academic/lecturer/widgets/lecturer_header.dart
import 'package:flutter/material.dart';
import '../../../../models/project_model.dart';
import '../../../../models/workspace_model.dart';
import '../../../../models/user_model.dart';
import '../view/profile_view.dart';
import '../lecturer_controller.dart'; // import controller

class LecturerHeader extends StatelessWidget {
  final ProjectModel? selectedProject;
  final WorkspaceModel? selectedWorkspace;
  final VoidCallback onBackPressed;
  final LecturerController controller; // Tambahan parameter controller

  const LecturerHeader({
    super.key,
    required this.selectedProject,
    required this.selectedWorkspace,
    required this.onBackPressed,
    required this.controller,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: controller.getCurrentUserProfile(),
      builder: (context, snapshot) {
        
        final user = snapshot.data;
        final String name = user?.fullName ?? "Dosen";
        final String initials = _getInitials(name);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (selectedProject != null || selectedWorkspace != null)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: onBackPressed,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedWorkspace != null
                        ? "Profil Kelompok"
                        : selectedProject != null
                            ? "Detail Proyek"
                            : "Halo, $name", // ---> NAMA DINAMIS DARI DATABASE <---
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    selectedWorkspace != null
                        ? selectedWorkspace!.teamName
                        : selectedProject != null
                            ? selectedProject!.title
                            : "Dosen Pengampu", // Teks disesuaikan
                    style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  // Lempar controller ke halaman profil
                  MaterialPageRoute(builder: (context) => ProfileView(controller: controller)),
                );
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.indigo,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      }
    );
  }
}