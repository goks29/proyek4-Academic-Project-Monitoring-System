import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'package:academic_project_monitoring_system/models/task_allocation_model.dart';
import 'package:academic_project_monitoring_system/models/submission_model.dart';
import 'workspace_task_controller.dart'; 


class WorkspaceTaskView extends StatefulWidget {
  final WorkspaceModel workspace;
  final TaskAllocationModel task;

  const WorkspaceTaskView({
    super.key,
    required this.workspace,
    required this.task,
  });

  @override
  State<WorkspaceTaskView> createState() => _WorkspaceTaskViewState();
}

class _WorkspaceTaskViewState extends State<WorkspaceTaskView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<WorkspaceTaskController>().loadTask(widget.task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceTaskController>();

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
      body: ctrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ctrl.errorMessage != null && ctrl.task == null
              ? Center(child: Text(ctrl.errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TaskDetailCard(task: ctrl.task ?? widget.task),
                      const SizedBox(height: 20),
                      ProgressSliderCard(taskId: widget.task.id),
                      const SizedBox(height: 20),
                      EvidenceUploadCard(task: ctrl.task ?? widget.task),
                      const SizedBox(height: 24),
                      const Text(
                        "Riwayat Pengumpulan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      // Oper data submissions dari controller ke UI Timeline
                      SubmissionTimelineList(submissions: ctrl.submissions),
                    ],
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
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
                    color: isDone ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  radius: 16,
                  child: const Icon(Icons.person, size: 18, color: Colors.blueAccent),
                ),
                const SizedBox(width: 10),
                Text(
                  "Petugas ID: ${task.studentId.substring(0, 5)}...",
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
  const ProgressSliderCard({super.key, required this.taskId});

  @override
  State<ProgressSliderCard> createState() => _ProgressSliderCardState();
}

class _ProgressSliderCardState extends State<ProgressSliderCard> {
  double _currentValue = 0;
  bool _hasChanged = false; 

  @override
  void initState() {
    super.initState();
    final initialProgress = context.read<WorkspaceTaskController>().task?.progress ?? 0;
    _currentValue = initialProgress.toDouble();
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
              onChanged: (val) {
                setState(() {
                  _currentValue = val;
                  _hasChanged = true;
                });
              },
            ),
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
                onPressed: (!_hasChanged || ctrl.isSaving)
                    ? null
                    : () async {
                        final ok = await context.read<WorkspaceTaskController>().updateProgress(widget.taskId, _currentValue.toInt());
                        if (ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress berhasil diupdate!"), backgroundColor: Colors.green));
                          setState(() => _hasChanged = false);
                        } else if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ctrl.errorMessage ?? "Gagal"), backgroundColor: Colors.red));
                        }
                      },
                child: ctrl.isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Simpan Progress", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// upload card
class EvidenceUploadCard extends StatefulWidget {
  final TaskAllocationModel task;
  const EvidenceUploadCard({super.key, required this.task});

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
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), style: BorderStyle.solid, width: 2),
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
                onPressed: (_selectedFile == null || ctrl.isSaving)
                    ? null
                    : () async {
                        final ok = await context.read<WorkspaceTaskController>().submitEvidence(
                          taskId: widget.task.id,
                          phaseId: widget.task.phaseId,
                          studentId: widget.task.studentId,
                          file: _selectedFile!,
                          notes: _notesController.text.trim(),
                        );
                        if (ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bukti berhasil dikirim!"), backgroundColor: Colors.green));
                          setState(() {
                            _selectedFile = null; 
                            _notesController.clear(); 
                          });
                        }
                      },
                child: ctrl.isSaving
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
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
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
                        "Dikirim: ${sub.submittedAt.toString().substring(0, 16)}", 
                        style: const TextStyle(fontSize: 12, color: Colors.grey)
                      ),
                      
                      // Munculkan Feedback Dosen 
                      if (sub.lecturerFeedback != null && sub.lecturerFeedback!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.2))
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
                    color: statusColor.withOpacity(0.1),
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