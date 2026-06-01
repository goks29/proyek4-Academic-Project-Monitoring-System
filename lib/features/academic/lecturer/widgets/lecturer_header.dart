import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/project_model.dart';
import '../../../../models/workspace_model.dart';
import '../../auth/login_controller.dart';
import '../view/profile_view.dart';

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

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // AMBIL DATA DINAMIS DARI LoginController
    final user = context.watch<LoginController>().currentUser;
    final String name = user?.fullName ?? "Dosen";
    final String initials = _getInitials(name);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (selectedProject != null || selectedWorkspace != null)
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: onBackPressed),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedWorkspace != null ? "Profil Kelompok" : selectedProject != null ? "Detail Proyek" : "Halo, $name",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis,
              ),
              Text(
                selectedWorkspace != null ? selectedWorkspace!.teamName : selectedProject != null ? selectedProject!.title : "Dosen Pengampu",
                style: TextStyle(color: Colors.blueGrey[400], fontSize: 14), overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileView())),
          child: CircleAvatar(backgroundColor: Colors.indigo, child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ],
    );
  }
}