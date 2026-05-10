// lib/features/academic/lecturer/widgets/dashboard_stats.dart
import 'package:flutter/material.dart';

class DashboardStats extends StatelessWidget {
  final int activeProjects;
  final int pendingReviews;

  const DashboardStats({
    super.key, 
    required this.activeProjects, 
    required this.pendingReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard("TUGAS BESAR AKTIF", activeProjects.toString(), Colors.indigoAccent[700]!, Colors.white),
        const SizedBox(width: 15),
        _statCard("BUTUH REVIEW", pendingReviews.toString(), Colors.white, Colors.orange, isBordered: true),
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
          border: isBordered ? Border.all(color: Colors.grey[300]!) : null
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
}