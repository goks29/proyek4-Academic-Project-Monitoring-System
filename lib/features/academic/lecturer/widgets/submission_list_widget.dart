// lib/features/academic/lecturer/widgets/submission_list_widget.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import package baru
import '../../../../models/submission_model.dart';
import '../../../../services/remote/submission_service.dart';

class SubmissionListWidget extends StatefulWidget {
  final List<SubmissionModel> submissions;
  final VoidCallback onSubmissionReviewed; 

  const SubmissionListWidget({
    super.key, 
    required this.submissions,
    required this.onSubmissionReviewed,
  });

  @override
  State<SubmissionListWidget> createState() => _SubmissionListWidgetState();
}

class _SubmissionListWidgetState extends State<SubmissionListWidget> {
  final SubmissionService _submissionService = SubmissionService(Supabase.instance.client);
  final String _lecturerId = Supabase.instance.client.auth.currentUser?.id ?? "d05e0001-0000-0000-0000-000000000000";

  String? _loadingSubmissionId;

  // FUNGSI UNTUK MEMBUKA LINK LANGSUNG KE BROWSER
  Future<void> _openLink(BuildContext context, String urlString) async {
    // Tambahkan https:// jika mahasiswa lupa mengetiknya
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka tautan: $urlString")),
        );
      }
    }
  }

  Future<void> _handleReview(BuildContext context, SubmissionModel submission, bool isApproved) async {
    final statusText = isApproved ? 'accepted' : 'rejected'; // Sesuai enum database
    final titleText = isApproved ? 'Terima Pengumpulan Ini?' : 'Minta Revisi?';
    final buttonColor = isApproved ? Colors.green.shade600 : Colors.red.shade600;
    
    final TextEditingController feedbackController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Berikan catatan untuk mahasiswa:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ketik catatan di sini...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: buttonColor)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _loadingSubmissionId = submission.id);

      try {
        await _submissionService.updateSubmissionReview(
          submission.id,
          statusText,
          feedbackController.text,
          _lecturerId,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Penilaian tersimpan!"), backgroundColor: Colors.green),
          );
          widget.onSubmissionReviewed(); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _loadingSubmissionId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.submissions.isEmpty) {
      return const Text("Belum ada pengumpulan.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.submissions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final sub = widget.submissions[index];
        final hasFile = sub.evidenceFileUrl != null && sub.evidenceFileUrl!.isNotEmpty;
        final isPending = sub.status.toLowerCase() == 'pending';
        final isLoading = _loadingSubmissionId == sub.id;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BARIS ATAS: Info vs Tombol Aksi di sebelahnya
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Dikirim: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                  // TOMBOL MENYAMPING (Hanya muncul jika Pending)
                  if (isPending)
                    if (isLoading)
                      const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () => _handleReview(context, sub, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade600, side: BorderSide(color: Colors.red.shade200),
                              padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 32),
                            ),
                            child: const Text("REVISI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: () => _handleReview(context, sub, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: const Size(0, 32),
                            ),
                            child: const Text("TERIMA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                  else
                    // Jika sudah dinilai, munculkan status badge saja
                    _buildStatusBadge(sub.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // CATATAN MAHASISWA
              if (sub.studentNotes != null && sub.studentNotes!.isNotEmpty) ...[
                Text('"${sub.studentNotes!}"', style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic, fontSize: 13)),
                const SizedBox(height: 12),
              ],

              // TOMBOL BUKA TAUTAN (Langsung buka browser)
              if (hasFile)
                InkWell(
                  onTap: () => _openLink(context, sub.evidenceFileUrl!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade100)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text("Buka Tautan", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

              // FEEDBACK DOSEN (Muncul jika sudah dinilai)
              if (!isPending && sub.lecturerFeedback != null && sub.lecturerFeedback!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Catatan Anda:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text(sub.lecturerFeedback!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.toLowerCase() == 'accepted' ? Colors.green.shade50 : Colors.red.shade50, 
        borderRadius: BorderRadius.circular(4)
      ),
      child: Text(
        status.toLowerCase() == 'accepted' ? "DITERIMA" : "REVISI", 
        style: TextStyle(
          color: status.toLowerCase() == 'accepted' ? Colors.green.shade700 : Colors.red.shade700, 
          fontSize: 10, fontWeight: FontWeight.bold
        )
      ),
    );
  }
}