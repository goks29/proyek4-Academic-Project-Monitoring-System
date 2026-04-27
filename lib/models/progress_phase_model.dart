import 'package:hive/hive.dart';

/*
 * Tabel: progress_phases
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh anggota kelompok dan dosen proyek terkait untuk keperluan sinkronisasi alur kerja tim dan pemantauan capaian oleh dosen.
 * - INSERT: Terbatas hanya untuk ketua kelompok karena ketua memiliki tanggung jawab manajerial dalam menyusun tahapan dan perencanaan kerja kelompok.
 * - UPDATE: Terbatas untuk ketua kelompok (khusus untuk mengubah penamaan/urutan fase) dan dosen proyek terkait (khusus untuk pembaruan status kelayakan dan umpan balik), guna memisahkan wewenang antara pihak yang mengeksekusi dan pihak yang mengevaluasi.
 * - DELETE: Tidak diizinkan melalui akses klien guna mempertahankan rekam jejak histori tahapan kerja yang telah dilalui.
 */

part 'progress_phase_model.g.dart';

/// Model data yang merepresentasikan tabel 'progress_phases' di database.
@HiveType(typeId: 1)
class ProgressPhaseModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workspaceId;

  @HiveField(2)
  final String phaseName;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final String status;

  ProgressPhaseModel({
    required this.id,
    required this.workspaceId,
    required this.phaseName,
    required this.sortOrder,
    required this.status,
  });

  /// Membuat instance ProgressPhaseModel dari format JSON Supabase.
  factory ProgressPhaseModel.fromJson(Map<String, dynamic> json) {
    return ProgressPhaseModel(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      phaseName: json['phase_name'] as String,
      sortOrder: json['sort_order'] as int,
      status: json['status'] as String,
    );
  }

  /// Mengonversi instance ProgressPhaseModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'phase_name': phaseName,
      'sort_order': sortOrder,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
