// lib/features/academic/lecturer/widgets/submission_list_widget.dart
import 'package:flutter/material.dart';
import '../../../../models/submission_model.dart';

class SubmissionListWidget extends StatelessWidget {
  final List<SubmissionModel> submissions;

  const SubmissionListWidget({super.key, required this.submissions});

  @override
  Widget build(BuildContext context) {
    if (submissions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Mahasiswa belum mengumpulkan berkas/link apapun.",
                style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true, // WAJIB ada kalau di dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: submissions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = submissions[index];
        final hasFile = sub.evidenceFileUrl != null && sub.evidenceFileUrl!.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.upload_file, color: Colors.indigo.shade400, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Pengumpulan #${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    "${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (sub.studentNotes != null && sub.studentNotes!.isNotEmpty) ...[
                Text(
                  '"${sub.studentNotes!}"',
                  style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              if (hasFile)
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("URL disalin: ${sub.evidenceFileUrl}")),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          "Buka File/Tautan",
                          style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  "Tidak ada file yang dilampirkan.",
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                ),
            ],
          ),
        );
      },
    );
  }
}