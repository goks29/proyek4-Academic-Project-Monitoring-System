// lib/features/academic/lecturer/widgets/workspace_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/workspace_model.dart';
import '../../../../controllers/lecturer/topic_approval_controller.dart';
import '../../../../repositories/workspace_member_repository.dart';
import '../../../../repositories/user_repository.dart';

// ==========================================
// WIDGET UNTUK HEADER & VALIDASI TOPIK (STATEFUL & OPTIMISTIC UPDATE)
// ==========================================
class WorkspaceHeaderWidget extends StatefulWidget {
  final WorkspaceModel initialWorkspace;
  final bool isProjectClosed;

  const WorkspaceHeaderWidget({
    super.key, 
    required this.initialWorkspace,
    this.isProjectClosed = false,
  });

  @override
  State<WorkspaceHeaderWidget> createState() => _WorkspaceHeaderWidgetState();
}

class _WorkspaceHeaderWidgetState extends State<WorkspaceHeaderWidget> {
  // Variabel untuk Optimistic Update UX
  String? _optimisticStatus;
  String? _optimisticFeedback;

  void _handleTopicReview(BuildContext context, WorkspaceModel currentWorkspace, bool isApproved) async {
    final statusText = isApproved ? 'accepted' : 'rejected';
    final titleText = isApproved ? 'Terima Topik Ini?' : 'Minta Ganti Topik?';
    final buttonColor = isApproved ? Colors.green.shade600 : Colors.red.shade600;
    
    final TextEditingController feedbackController = TextEditingController();
    if (currentWorkspace.lecturerFeedback != null) {
      feedbackController.text = currentWorkspace.lecturerFeedback!;
    }

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
              const Text("Berikan catatan terkait topik ini:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Contoh: Topik terlalu luas...",
                  filled: true, fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: buttonColor)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: Colors.white),
              child: const Text("Kirim"),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // Panggil API lewat provider
      await context.read<TopicApprovalController>().approveTopic(
        currentWorkspace.id,
        statusText,
        feedbackController.text,
      );
      
      if (mounted) {
        // ---> OPTIMISTIC UPDATE: Ubah UI secara instan <---
        setState(() {
          _optimisticStatus = statusText;
          _optimisticFeedback = feedbackController.text;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Penilaian topik tersimpan!"), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicCtrl = context.watch<TopicApprovalController>();
    
    // Cari data terbaru dari provider, jika tidak ketemu, pakai data inisial
    final workspace = topicCtrl.workspaces.firstWhere(
      (w) => w.id == widget.initialWorkspace.id, 
      orElse: () => widget.initialWorkspace
    );

    final bool hasTopic = workspace.topicName?.isNotEmpty ?? false;
    
    // ---> GUNAKAN DATA OPTIMISTIS JIKA ADA <---
    final String status = (_optimisticStatus ?? workspace.status ?? 'pending').toLowerCase();
    final String? currentFeedback = _optimisticFeedback ?? workspace.lecturerFeedback;
    final bool isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(workspace.teamName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
              if (hasTopic) _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 16),
          Text("Topik Tugas Besar:", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(
            hasTopic ? workspace.topicName! : "Topik belum ditentukan oleh mahasiswa",
            style: TextStyle(
              fontSize: 16, color: hasTopic ? Colors.black87 : Colors.red.shade400,
              fontStyle: hasTopic ? FontStyle.normal : FontStyle.italic,
              fontWeight: hasTopic ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (hasTopic && workspace.topicDescription != null && workspace.topicDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(workspace.topicDescription!, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          ],
          
          // Tampilkan feedback dosen
          if (!isPending && currentFeedback != null && currentFeedback.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Catatan Anda:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text(currentFeedback, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
          ],

          if (workspace.isCompleted || widget.isProjectClosed) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, 
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    "PROYEK TELAH DITUTUP", 
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] 
          // Jika belum selesai, baru tampilkan tombol ACC/TOLAK
          else if (hasTopic && isPending) ...[
            const SizedBox(height: 16),
            if (topicCtrl.isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.indigo))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleTopicReview(context, workspace, false),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade600, side: BorderSide(color: Colors.red.shade200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text("TOLAK TOPIK", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleTopicReview(context, workspace, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text("ACC TOPIK", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg; Color fg; String text;
    switch (status) {
      case 'accepted': case 'approved': bg = Colors.green.shade50; fg = Colors.green.shade700; text = "TOPIK DI-ACC"; break;
      case 'rejected': case 'revisi': bg = Colors.red.shade50; fg = Colors.red.shade700; text = "TOPIK DITOLAK"; break;
      default: bg = Colors.orange.shade50; fg = Colors.orange.shade700; text = "MENUNGGU ACC";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ==========================================
// WIDGET LIST ANGGOTA (Dengan Proteksi Null-Safety)
// ==========================================
class WorkspaceMembersWidget extends StatelessWidget {
  final WorkspaceModel workspace;

  const WorkspaceMembersWidget({
    super.key, 
    required this.workspace, 
  });

  Future<List<Map<String, dynamic>>> _fetchMembers(BuildContext context) async {
    final memberRepo = context.read<WorkspaceMemberRepository>();
    final userRepo = context.read<UserRepository>();
    final members = await memberRepo.getMembers(workspace.id);
    
    List<Map<String, dynamic>> detailedMembers = [];
    for (var member in members) {
      final userProfile = await userRepo.getUser(member.studentId);
      detailedMembers.add({
        'role': member.isLeader ? 'Ketua' : 'Anggota',
        // ---> PERBAIKAN: Cegah Crash karena Null-Safety <---
        'name': userProfile.fullName ?? 'Mahasiswa Anonim',
        'email': userProfile.email ?? 'Tidak ada email'
      });
    }
    return detailedMembers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMembers(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(strokeWidth: 2)));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text("Belum ada anggota terdaftar.", style: TextStyle(color: Colors.grey.shade500))));
        
        final members = snapshot.data!;
        return ListView.separated(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: members.length, separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            final isLeader = member['role'] == 'Ketua';
            
            // Ambil huruf pertama dari nama dengan aman
            final String nameStr = member['name'] as String;
            final String firstLetter = nameStr.isNotEmpty ? nameStr.substring(0, 1).toUpperCase() : "?";

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              leading: CircleAvatar(
                backgroundColor: isLeader ? Colors.amber.shade100 : Colors.indigo.shade50,
                child: Text(firstLetter, style: TextStyle(color: isLeader ? Colors.amber.shade900 : Colors.indigo.shade700, fontWeight: FontWeight.bold)),
              ),
              title: Text(nameStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text(member['email'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              trailing: isLeader ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)), child: Text("Ketua", style: TextStyle(color: Colors.amber.shade800, fontSize: 11, fontWeight: FontWeight.bold))) : null,
            );
          },
        );
      },
    );
  }
}