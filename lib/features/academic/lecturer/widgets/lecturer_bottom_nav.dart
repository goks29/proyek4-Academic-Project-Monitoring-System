import 'package:flutter/material.dart';
import '../view/add_project_view.dart';

class LecturerBottomNav extends StatelessWidget {
  final VoidCallback onRefresh;

  const LecturerBottomNav({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      onTap: (index) async {
        if (index == 1) {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProjectView()));
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