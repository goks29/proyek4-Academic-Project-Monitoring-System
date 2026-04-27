import 'package:hive/hive.dart';
import '../../models/comment_model.dart';

// Local service for comments table
/// Layanan untuk mengelola penyimpanan komentar di database lokal (Hive).
class CommentLocalService {
  final Box<CommentModel> _box;

  CommentLocalService(this._box);

  /// Mengambil daftar komentar berdasarkan ID submission dari storage lokal.
  List<CommentModel> getCommentsBySubmissionId(String submissionId) {
    return _box.values.where((comment) => comment.submissionId == submissionId).toList();
  }

  /// Menyimpan satu data komentar ke storage lokal.
  Future<void> saveComment(CommentModel comment) async {
    await _box.put(comment.id, comment);
    print('Comment ${comment.id} saved to local storage.');
  }

  /// Menyimpan daftar komentar sekaligus ke storage lokal.
  Future<void> saveAllComments(List<CommentModel> comments) async {
    final Map<String, CommentModel> commentMap = {
      for (var c in comments) c.id: c
    };
    await _box.putAll(commentMap);
    print('${comments.length} comments saved to local storage.');
  }

  Future<void> clearComments() async {
    await _box.clear();
  }
}
