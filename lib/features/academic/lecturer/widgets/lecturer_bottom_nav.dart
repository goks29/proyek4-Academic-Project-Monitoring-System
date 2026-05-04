// lib/features/academic/lecturer/widgets/lecturer_bottom_nav.dart
import 'package:flutter/material.dart';
import '../view/add_project_view.dart';
import '../lecturer_controller.dart';

class LecturerBottomNav extends StatelessWidget {
  final LecturerController controller;
  final VoidCallback onRefresh;

  const LecturerBottomNav({super.key, required this.controller, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      onTap: (index) async {
        // Index 1 sekarang adalah tombol "TAMBAH"
        if (index == 1) {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddProjectView())
          );
          if (result == true) onRefresh();
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'BERANDA'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'TAMBAH'),
      ],
    );
  }
}