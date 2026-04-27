import 'package:flutter/material.dart';
import 'home_page.dart';

class StudentView extends StatefulWidget{
  @override
  _StudentViewState createState() => _StudentViewState(); 
}

class _StudentViewState extends State<StudentView> {
  int _currentIndex = 0;

  void _changeMenu(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _page = [
    HomePage(),
    const Text("ayam"),
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
            icon: Icon(Icons.assignment),
            label: 'Tugas'
          )
        ],
      ),
    );
  }
}