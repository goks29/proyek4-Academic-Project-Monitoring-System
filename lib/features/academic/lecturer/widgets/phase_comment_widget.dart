// lib/features/academic/lecturer/widgets/phase_comment_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/comment_model.dart';
import '../../../../models/progress_phase_model.dart';
import '../../../../controllers/lecturer/comment_controller.dart';

class PhaseCommentWidget extends StatefulWidget {
  final ProgressPhaseModel phase;
  final bool isReadOnly;

  const PhaseCommentWidget({
    super.key, 
    required this.phase,
    this.isReadOnly = false,
  });

  @override
  State<PhaseCommentWidget> createState() => _PhaseCommentWidgetState();
}

class _PhaseCommentWidgetState extends State<PhaseCommentWidget> {
  final TextEditingController _chatController = TextEditingController();
  // HARDCODE DIHAPUS
  final String _myUserId = Supabase.instance.client.auth.currentUser?.id ?? "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentController>().fetchCommentsByPhase(widget.phase.id);
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _myUserId.isEmpty) return; // Tambahan handle anti-error _myUserId.isEmpty

    final comment = CommentModel(id: '', phaseId: widget.phase.id, userId: _myUserId, commentText: text, clientCreatedAt: DateTime.now());
    await context.read<CommentController>().addComment(comment);
    
    if (mounted) _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final commentCtrl = context.watch<CommentController>();
    final comments = commentCtrl.comments.reversed.toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(color: Color(0xFFF4F6F9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ruang Diskusi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.phase.phaseName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: commentCtrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? Center(child: Text("Belum ada diskusi.", style: TextStyle(color: Colors.grey.shade500)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        reverse: true,
                        itemCount: comments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = comments[index];
                          final isMe = chat.userId == _myUserId;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.indigo.shade600 : Colors.white,
                                borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
                                border: isMe ? null : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(isMe ? "Saya" : "Mahasiswa", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isMe ? Colors.indigo.shade100 : Colors.grey.shade500)),
                                  const SizedBox(height: 4),
                                  Text(chat.commentText, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          
          widget.isReadOnly 
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: Colors.white,
                child: SafeArea(
                  child: Center(
                    child: Text("Diskusi dikunci karena proyek telah ditutup.", style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontSize: 13)),
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(hintText: "Ketik pesan diskusi...", hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sendMessage),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}