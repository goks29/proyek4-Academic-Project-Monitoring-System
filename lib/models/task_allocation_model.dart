import 'package:hive/hive.dart';

/*
 * Tabel: task_allocations
 * Operasi & Aturan Bisnis:
 * - SELECT: Dapat diakses oleh anggota kelompok dan dosen proyek terkait agar seluruh entitas di dalam tim dapat melacak distribusi beban kerja secara transparan.
 * - INSERT: Terbatas hanya untuk ketua kelompok sebagai manifestasi dari peran ketua dalam melakukan delegasi tugas kepada anggota.
 * - UPDATE: Terbatas untuk ketua kelompok (pembaruan deskripsi tugas), mahasiswa yang ditugaskan (pelaporan penyelesaian tugas), dan dosen proyek terkait (validasi hasil), guna menciptakan alur kerja yang akuntabel sesuai dengan porsi tanggung jawab masing-masing.
 * - DELETE: Tidak diizinkan melalui akses klien agar riwayat kontribusi individu tidak dapat dihilangkan.
 */

part 'task_allocation_model.g.dart';

/// Model data yang merepresentasikan tabel 'task_allocations' di database.
@HiveType(typeId: 2)
class TaskAllocationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String phaseId;

  @HiveField(2)
  final String studentId;

  @HiveField(3)
  final String taskDescription;

  @HiveField(4)
  final bool isDone;

  @HiveField(5)
  final String status;

  TaskAllocationModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.taskDescription,
    required this.isDone,
    required this.status,
  });

  /// Membuat instance TaskAllocationModel dari format JSON Supabase.
  factory TaskAllocationModel.fromJson(Map<String, dynamic> json) {
    return TaskAllocationModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String,
      studentId: json['student_id'] as String,
      taskDescription: json['task_description'] as String,
      isDone: json['is_done'] as bool,
      status: json['status'] as String,
    );
  }

  /// Mengonversi instance TaskAllocationModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'task_description': taskDescription,
      'client_created_at': DateTime.now().toIso8601String(),
    };
  }
}
