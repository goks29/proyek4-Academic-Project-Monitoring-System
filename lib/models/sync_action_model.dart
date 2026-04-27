import 'package:hive/hive.dart';

part 'sync_action_model.g.dart';

/// Model data untuk mencatat aksi mutasi (INSERT/UPDATE/DELETE) saat aplikasi offline.
@HiveType(typeId: 8)
class SyncActionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String table;

  @HiveField(2)
  final String method; // Contoh: insert, update, delete

  @HiveField(3)
  final Map<dynamic, dynamic> payload;

  @HiveField(4)
  final DateTime createdAt;

  SyncActionModel({
    required this.id,
    required this.table,
    required this.method,
    required this.payload,
    required this.createdAt,
  });
}
