// lib/features/academic/lecturer/widgets/phase_comment_widget.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/comment_model.dart';
import '../../../../models/progress_phase_model.dart';
import '../lecturer_controller.dart';

class PhaseCommentWidget extends StatefulWidget {
  final ProgressPhaseModel phase;
  final LecturerController controller;

  const PhaseCommentWidget({
    super.key,
    required this.phase,
    required this.controller,
  });

  @override
  State<PhaseCommentWidget> createState() => _PhaseCommentWidgetState();
}

class _PhaseCommentWidgetState extends State<PhaseCommentWidget> {
  final TextEditingController _chatController = TextEditingController();
  final String _myUserId = Supabase.instance.client.auth.currentUser?.id ?? "d05e0001-0000-0000-0000-000000000000";
  
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final data = await widget.controller.getPhaseComments(widget.phase.id);
    if (mounted) {
      setState(() {
        _comments = data.reversed.toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final success = await widget.controller.sendPhaseComment(widget.phase.id, text);
    
    if (success && mounted) {
      _chatController.clear();
      await _loadComments(); // Refresh list chat
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengirim pesan.")));
    }

    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    // Membuat Bottom Sheet responsif terhadap keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8, // Maksimal 80% layar
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Chat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
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
          
          // Area List Chat
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(child: Text("Belum ada diskusi.", style: TextStyle(color: Colors.grey.shade500)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        reverse: true, // Chat terbaru di bawah (jika list di-reverse, tapi default Supabase ascending)
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = _comments[index];
                          final isMe = chat.userId == _myUserId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75, // <--- BUNGKUS DENGAN BoxConstraints
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.indigo.shade600 : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                border: isMe ? null : Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMe ? "Saya" : "Mahasiswa",
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isMe ? Colors.indigo.shade100 : Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat.commentText,
                                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Area Ketik Pesan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan diskusi...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: _isSending
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}