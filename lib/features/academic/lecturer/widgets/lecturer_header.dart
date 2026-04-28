// lib/features/academic/lecturer/widgets/lecturer_header.dart
import 'package:flutter/material.dart';
import '../../../../models/project_model.dart';
import '../../../../models/workspace_model.dart';

class LecturerHeader extends StatelessWidget {
  final ProjectModel? selectedProject;
  final WorkspaceModel? selectedWorkspace;
  final VoidCallback onBackPressed;

  const LecturerHeader({
    super.key,
    required this.selectedProject,
    required this.selectedWorkspace,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                        : "Halo, Pak Arnold",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                selectedWorkspace != null
                    ? selectedWorkspace!.teamName
                    : selectedProject != null
                        ? selectedProject!.title
                        : "Dosen Pengampu JTK",
                style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.indigo,
          child: Text("AB", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}