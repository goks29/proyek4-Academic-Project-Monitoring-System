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

  @HiveField(6)
  final String? lecturerFeedback;

  @HiveField(7)
  final DateTime clientCreatedAt;

  @HiveField(8)
  final DateTime? serverReceivedAt;

  /// Persentase progress pengerjaan (0–100).
  /// Tidak disimpan ke Hive (transient), diisi saat fetch dari cloud.
  final int progress;

  TaskAllocationModel({
    required this.id,
    required this.phaseId,
    required this.studentId,
    required this.taskDescription,
    this.isDone = false,
    required this.status,
    this.lecturerFeedback,
    required this.clientCreatedAt,
    this.serverReceivedAt,
    this.progress = 0,
  });

  /// Membuat instance TaskAllocationModel dari format JSON Supabase.
  factory TaskAllocationModel.fromJson(Map<String, dynamic> json) {
    return TaskAllocationModel(
      id: json['id'] as String,
      phaseId: json['phase_id'] as String,
      studentId: json['student_id'] as String,
      taskDescription: json['task_description'] as String,
      isDone: json['is_done'] as bool? ?? false,
      status: json['status'] as String,
      lecturerFeedback: json['lecturer_feedback'] as String?,
      clientCreatedAt: DateTime.parse(json['client_created_at'] as String),
      serverReceivedAt: json['server_received_at'] != null 
          ? DateTime.parse(json['server_received_at'] as String) 
          : null,
      progress: json['progress'] as int? ?? 0,
    );
  }

  /// Mengonversi instance TaskAllocationModel ke format JSON untuk Supabase.
  Map<String, dynamic> toJson() {
    return {
      'phase_id': phaseId,
      'student_id': studentId,
      'task_description': taskDescription,
      'is_done': isDone,
      'status': status,
      'lecturer_feedback': lecturerFeedback,
      'client_created_at': clientCreatedAt.toIso8601String(),
    };
  }

  TaskAllocationModel copyWith({
    String? id,
    String? phaseId,
    String? studentId,
    String? taskDescription,
    bool? isDone,
    String? status,
    String? lecturerFeedback,
    DateTime? clientCreatedAt,
    DateTime? serverReceivedAt,
    int? progress,
  }) {
    return TaskAllocationModel(
      id: id ?? this.id,
      phaseId: phaseId ?? this.phaseId,
      studentId: studentId ?? this.studentId,
      taskDescription: taskDescription ?? this.taskDescription,
      isDone: isDone ?? this.isDone,
      status: status ?? this.status,
      lecturerFeedback: lecturerFeedback ?? this.lecturerFeedback,
      clientCreatedAt: clientCreatedAt ?? this.clientCreatedAt,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      progress: progress ?? this.progress,
    );
  }
}
