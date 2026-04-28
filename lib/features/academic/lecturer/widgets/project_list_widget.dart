// lib/features/academic/lecturer/widgets/project_list_widget.dart
import 'package:flutter/material.dart';
import '../../../../models/project_model.dart';

class ProjectListWidget extends StatelessWidget {
  final Future<List<ProjectModel>> projectsFuture;
  final String searchQuery;
  final Function(ProjectModel) onProjectSelected;

  const ProjectListWidget({
    super.key,
    required this.projectsFuture,
    required this.searchQuery,
    required this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProjectModel>>(
      future: projectsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final filtered = snapshot.data!.where((p) => p.title.toLowerCase().contains(searchQuery)).toList();
        if (filtered.isEmpty) return const Center(child: Text("Tugas besar tidak ditemukan."));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final project = filtered[i];
            return GestureDetector(
              onTap: () => onProjectSelected(project),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.red[50]!, borderRadius: BorderRadius.circular(8)),
                          child: Text("On Progress", style: TextStyle(color: Colors.red[400]!, fontSize: 10)),
                        ),
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
          },
        );
      },
    );
  }
}