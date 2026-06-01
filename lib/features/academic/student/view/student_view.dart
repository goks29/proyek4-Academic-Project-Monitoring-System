import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../controller/workspace_controller.dart';
import 'workspace_home_view.dart';
import 'home_page.dart';

class StudentView extends StatefulWidget{
  @override
  _StudentViewState createState() => _StudentViewState(); 
}

class _StudentViewState extends State<StudentView> {
  int _currentIndex = 0;

  // Buka halaman tambah workspace atau ganti tab
  void _changeMenu(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => WorkspaceHomeView(),
        ),
      ).then((_) {
        context.read<WorkspaceController>().fetchMyWorkspaces();
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  late final List<Widget> _page = [
    HomePage(),
    const SizedBox(), // Placeholder halaman (tidak ditampilkan karena navigasi push)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changeMenu,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Tambah'
          )
        ],
      ),
    );
  }
}