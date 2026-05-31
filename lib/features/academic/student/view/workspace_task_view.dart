import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'package:academic_project_monitoring_system/models/pending_submission_model.dart';
import 'package:academic_project_monitoring_system/core/offline/connectivity_monitor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/workspace_task_controller.dart'; 
import '../controller/workspace_detail_controller.dart'; 

class WorkspaceTaskView extends StatefulWidget {
  final WorkspaceModel workspace;
  final TaskAllocationModel task;
  final DateTime? phaseDeadline;

  const WorkspaceTaskView({
    super.key,
    required this.workspace,
    required this.task,
    this.phaseDeadline,
  });

  @override
  State<WorkspaceTaskView> createState() => _WorkspaceTaskViewState();
}

class _WorkspaceTaskViewState extends State<WorkspaceTaskView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final ctrl = context.read<WorkspaceTaskController>();
      ctrl.setPhaseDeadline(widget.phaseDeadline);
      await ctrl.loadTask(widget.task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceTaskController>();
    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final bool isOwner = currentUserId == widget.task.studentId;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: const Text(
          "Detail Tugas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ctrl.errorMessage != null && ctrl.task == null
              ? Center(child: Text(ctrl.errorMessage!))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offline status banner
                      _OfflineStatusBanner(),
                      // Deadline banner
                      _DeadlineBanner(),
                      TaskDetailCard(task: ctrl.task ?? widget.task),
                      const SizedBox(height: 20),
                      ProgressSliderCard(
                        taskId: widget.task.id,
                        isOwner: isOwner,
                      ),
                      const SizedBox(height: 20),
                      EvidenceUploadCard(
                        task: ctrl.task ?? widget.task,
                        isOwner: isOwner,
                      ),
                      // Pending sync section
                      if (ctrl.hasPendingSync) ...[
                        const SizedBox(height: 24),
                        const Text(
                          "Menunggu Sinkronisasi",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        const SizedBox(height: 8),
                        _PendingSyncList(pendingSubmissions: ctrl.pendingSubmissions),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        "Riwayat Pengumpulan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SubmissionTimelineList(submissions: ctrl.submissions),
                    ],
                  ),
                ),
      ),
    );
  }
}


// task detail card
class TaskDetailCard extends StatelessWidget {
  final TaskAllocationModel task;
  const TaskDetailCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.isDone;
    final ctrl_detail = context.watch<WorkspaceDetailController>();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.taskDescription,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isDone ? "Selesai" : "Proses",
                    style: TextStyle(
                      color: isDone ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                  radius: 16,
                  child: const Icon(Icons.person, size: 18, color: Colors.blueAccent),
                ),
                const SizedBox(width: 10),
                Text(
                  "Nama Petugas: ${ctrl_detail.getStudentName(task.studentId)}",
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// progress slider card
class ProgressSliderCard extends StatefulWidget {
  final String taskId;
  final bool isOwner;
  const ProgressSliderCard({super.key, required this.taskId, required this.isOwner});

  @override
  State<ProgressSliderCard> createState() => _ProgressSliderCardState();
}

class _ProgressSliderCardState extends State<ProgressSliderCard> {
  double _currentValue = 0;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _currentValue = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasChanged) {
      final latestProgress =
          context.read<WorkspaceTaskController>().task?.progress ?? 0;
      if (latestProgress.toDouble() != _currentValue) {
        setState(() => _currentValue = latestProgress.toDouble());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceTaskController>();

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Update Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${_currentValue.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 10),
            Slider(
              value: _currentValue,
              min: 0,
              max: 100,
              divisions: 10,
              activeColor: Colors.blueAccent,
              label: "${_currentValue.toInt()}%",
              onChanged: (widget.isOwner && !ctrl.isDeadlinePassed)
                ? (val) {
                    setState(() {
                      _currentValue = val;
                      _hasChanged = true;
                    });
                  } 
                : null,
            ),
            if (widget.isOwner) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey[300], 
                  ),
                  onPressed: (!_hasChanged || ctrl.isSavingProgress)
                      ? null
                      : () async {
                          final ok = await context.read<WorkspaceTaskController>().updateProgress(widget.taskId, _currentValue.toInt());
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Progress berhasil diupdate!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                            setState(() => _hasChanged = false);
                          } else if (!ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ctrl.errorMessage ?? "Gagal menyimpan progress"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                          }
                        },
                  child: ctrl.isSavingProgress
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Progress", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),

              ),
            ],
          ],
        ),
      ),
    );
  }
}

// upload card
class EvidenceUploadCard extends StatefulWidget {
  final TaskAllocationModel task;
  final bool isOwner;
  const EvidenceUploadCard({super.key, required this.task, required this.isOwner});

  @override
  State<EvidenceUploadCard> createState() => _EvidenceUploadCardState();
}

class _EvidenceUploadCardState extends State<EvidenceUploadCard> {
  final TextEditingController _notesController = TextEditingController();
  XFile? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFile = image;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceTaskController>();
    
    if (!widget.isOwner) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Upload Bukti Pengerjaan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.isOwner ? _pickImage : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5), style: BorderStyle.solid, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(_selectedFile == null ? Icons.cloud_upload_outlined : Icons.check_circle, size: 40, color: Colors.blueAccent),
                      const SizedBox(height: 10),
                      Text(
                        _selectedFile == null ? "Tap untuk pilih gambar bukti" : "File siap diupload",
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      if (_selectedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_selectedFile!.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                enabled: widget.isOwner,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Tulis catatan pengerjaan di sini...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16)
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (!widget.isOwner|| _selectedFile == null || ctrl.isSavingEvidence)
                      ? null
                      : () async {
                          final ok = await context.read<WorkspaceTaskController>().submitEvidence(
                            taskId: widget.task.id,
                            studentId: widget.task.studentId,
                            file: _selectedFile!,
                            notes: _notesController.text.trim(),
                          );
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bukti berhasil dikirim!"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                            setState(() {
                              _selectedFile = null;
                              _notesController.clear();
                            });
                          } else if (!ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(context.read<WorkspaceTaskController>().errorMessage ?? "Gagal mengirim bukti"),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                  child: ctrl.isSavingEvidence
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Kirim Bukti", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );
  }
}

// time list
class SubmissionTimelineList extends StatelessWidget {
  final List<SubmissionModel> submissions;

  const SubmissionTimelineList({super.key, required this.submissions});

  @override
  Widget build(BuildContext context) {
    if (submissions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text("Belum ada bukti yang diunggah.", style: TextStyle(color: Colors.grey))),
      );
    }

    return ListView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(), 
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final sub = submissions[index];
        final hasFile = sub.evidenceFileUrl != null && sub.evidenceFileUrl!.isNotEmpty;
        
        // Atur warna status (Pending/Approved/Rejected)
        Color statusColor = Colors.orange;
        String statusText = "Menunggu";
        if (sub.status.toLowerCase() == 'approved') {
          statusColor = Colors.green;
          statusText = "Diterima";
        } else if (sub.status.toLowerCase() == 'rejected') {
          statusColor = Colors.red;
          statusText = "Ditolak";
        }

        return Card(
          color: Colors.white,
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon Lampiran File/Teks
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(hasFile ? Icons.image : Icons.text_snippet, color: Colors.blueAccent),
                ),
                const SizedBox(width: 12),
                
                // Area Konten (Notes, Tanggal, Feedback Dosen)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.studentNotes != null && sub.studentNotes!.isNotEmpty 
                            ? sub.studentNotes! 
                            : "Tanpa Catatan", 
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // Memotong format DateTime jadi cuma YYYY-MM-DD HH:MM
                        "Dikirim: ${sub.submittedAt.toLocal().toString().substring(0, 16)}", 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)
                      ),
                      
                      // Munculkan Feedback Dosen 
                      if (sub.lecturerFeedback != null && sub.lecturerFeedback!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.2))
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.feedback_outlined, size: 14, color: Colors.red),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Feedback Dosen:\n${sub.lecturerFeedback!}",
                                  style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                ),
                
                // Badge Status di sebelah kanan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────── Offline Status Banner ───────────────────────

class _OfflineStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Coba ambil ConnectivityMonitor dari Provider tree
    final connectivity = context.watch<ConnectivityMonitor>();
    
    if (connectivity.isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pengumpulan tugas akan disimpan lokal dan dikirim saat online kembali.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 11,
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

// ─────────────────────── Pending Sync List ───────────────────────

class _PendingSyncList extends StatelessWidget {
  final List<PendingSubmissionModel> pendingSubmissions;
  
  const _PendingSyncList({required this.pendingSubmissions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingSubmissions.length,
      itemBuilder: (context, index) {
        final pending = pendingSubmissions[index];
        return Card(
          color: Colors.orange.withValues(alpha: 0.05),
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pending.notes ?? 'Tanpa Catatan',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Disimpan: ${pending.createdAt.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'File: ${pending.fileName}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (pending.syncError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Error: ${pending.syncError}',
                          style: const TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Pending',
                        style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────── Deadline Banner ───────────────────────

class _DeadlineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceTaskController>();
    final deadline = ctrl.phaseDeadline;

    if (deadline == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final isPassed = now.isAfter(deadline);

    if (isPassed) {
      // Deadline sudah lewat
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_clock, color: Colors.red, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deadline Telah Terlewati',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Deadline: ${_formatDateTime(deadline)}. Anda tidak dapat mengupdate progress atau mengumpulkan bukti.',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Deadline belum lewat — tampilkan countdown
    final remaining = deadline.difference(now);
    final remainingText = _formatDuration(remaining);

    // Warna berdasarkan urgensi
    final isUrgent = remaining.inHours < 24;
    final color = isUrgent ? Colors.orange : Colors.green;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isUrgent ? Icons.warning_amber_rounded : Icons.schedule,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sisa Waktu: $remainingText',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Deadline: ${_formatDateTime(deadline)}',
                  style: TextStyle(
                    color: color.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final localDt = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${localDt.day} ${months[localDt.month - 1]} ${localDt.year}, '
        '${localDt.hour.toString().padLeft(2, '0')}:'
        '${localDt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      final hours = d.inHours % 24;
      return '${d.inDays} hari ${hours > 0 ? '$hours jam' : ''}';
    } else if (d.inHours > 0) {
      final minutes = d.inMinutes % 60;
      return '${d.inHours} jam ${minutes > 0 ? '$minutes menit' : ''}';
    } else {
      return '${d.inMinutes} menit';
    }
  }
}