import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import '../controller/workspace_detail_controller.dart';
import 'phase_task_setup_page.dart';
import 'workspace_task_view.dart'; 
import '../controller/workspace_task_controller.dart'; 
import 'package:academic_project_monitoring_system/core/offline/offline_submission_manager.dart';


class WorkspaceDetailView extends StatefulWidget {
  final WorkspaceModel workspace;

  const WorkspaceDetailView(
    {super.key, required this.workspace}
  );

  @override
  State<WorkspaceDetailView> createState() => _WorkspaceDetailViewState();
}

class _WorkspaceDetailViewState extends State<WorkspaceDetailView> {
  late bool _isLeader;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _isLeader = false;
    Future.microtask(() async {
      await context.read<WorkspaceDetailController>().loadWorkspaceData(widget.workspace.id);
      if (mounted) _resolveLeaderStatus();
    });
  }

  void _resolveLeaderStatus() {
    if (!mounted) return;
    final ctrl = context.read<WorkspaceDetailController>();
    setState(() {
      _isLeader = ctrl.isCurrentUserLeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceDetailController>();
    final ws = ctrl.currentWorkspace ?? widget.workspace;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail ${ws.teamName}",
          style: const TextStyle(
              color: Colors.blueAccent, fontWeight: FontWeight.bold,),
        ),
        actions: [
          // Bagikan ID workspace
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.blueAccent),
            tooltip: 'Bagikan ID Kelompok',
            onPressed: () => _showShareIdDialog(context, ws.id),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ctrl.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
              onRefresh: () => ctrl.loadWorkspaceData(ws.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card 
                    _InfoCard(workspace: ws),
                    const SizedBox(height: 20),

                    // Aksi Ketua 
                    if (_isLeader) ...[
                      const _SectionHeader(title: 'Aksi Ketua'),
                      const SizedBox(height: 12),
                      _LeaderActionsGrid(
                        workspace: ws,
                        controller: ctrl,
                        currentUserId: _currentUserId,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Anggota
                    const _SectionHeader(title: 'Anggota Kelompok'),
                    const SizedBox(height: 12),
                    _MemberList(controller: ctrl),
                    const SizedBox(height: 24),

                    // Phase & Task 
                    const _SectionHeader(title: 'Progress Phase & Task'),
                    const SizedBox(height: 12),
                    _PhaseTaskList(controller: ctrl, workspace: ws,),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  void _showShareIdDialog(BuildContext context, String workspaceId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ID Kelompok', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bagikan ID ini kepada anggota yang ingin bergabung:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      workspaceId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace', fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 20, color: Colors.white),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: workspaceId));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ID kelompok disalin!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

// Info Card 

class _InfoCard extends StatelessWidget {
  final WorkspaceModel workspace;
  const _InfoCard({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final ws = workspace;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ws.teamName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _InfoRow(
              icon: Icons.folder_outlined,
              text: (ws.joinCode == null || ws.joinCode!.isEmpty)
                  ? 'Belum terhubung ke project dosen'
                  : 'Project: ${ws.projectName ?? ws.joinCode}'),
          const SizedBox(height: 4),
          _InfoRow(
              icon: Icons.topic_outlined,
              text: (ws.topicName?.isEmpty ?? true)
                  ? 'Topik belum diajukan'
                  : ws.topicName!),
          if (ws.topicDescription != null && ws.topicDescription!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.notes_outlined, text: ws.topicDescription!),
          ],
          const SizedBox(height: 4),
          _InfoRow(
              icon: ws.isCompleted ? Icons.check_circle : Icons.pending,
              text: ws.isCompleted ? 'Selesai' : 'Sedang berjalan'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85), fontSize: 13)),
        ),
      ],
    );
  }
}

// Section Header 

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142)));
  }
}

// Leader Actions 

class _LeaderActionsGrid extends StatelessWidget {
  final WorkspaceModel workspace;
  final WorkspaceDetailController controller;
  final String currentUserId;

  const _LeaderActionsGrid({
    required this.workspace,
    required this.controller,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyLinked = workspace.joinCode != null && workspace.joinCode!.isNotEmpty;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        // Join Project — dinonaktifkan jika sudah terhubung
        _ActionTile(
          icon: Icons.link_rounded,
          label: alreadyLinked ? 'Sudah Terhubung' : 'Join Project Dosen',
          color: alreadyLinked ? Colors.grey : Colors.teal,
          isDisabled: alreadyLinked,
          onTap: alreadyLinked ? null : () => _showJoinProjectDialog(context),
        ),
        // Ajukan Topik
        _ActionTile(
          icon: Icons.topic_rounded,
          label: 'Ajukan Topik',
          color: Colors.orange,
          onTap: () => _showSubmitTopicDialog(context),
        ),
        // Atur Phase & Task menggabungkan 2 tombol lama menjadi 1 halaman
        _ActionTile(
          icon: Icons.layers_rounded,
          label: 'Atur Phase & Task',
          color: Colors.purple,
          onTap: () => _openPhaseTaskSetup(context),
        ),
      ],
    );
  }

  // Buka halaman Atur Phase & Task 
  Future<void> _openPhaseTaskSetup(BuildContext context) async {
    if (controller.workspaceMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada anggota untuk dialokasikan tugas.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final result = await Navigator.push<bool>(
      context,
      CupertinoPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: PhaseTaskSetupPage(
            workspaceId: workspace.id,
            members: controller.workspaceMembers,
          ),
        ),
      ),
    );
    // Jika ada data baru tersimpan, refresh detail
    if (result == true && context.mounted) {
      await controller.loadWorkspaceData(workspace.id);
    }
  }

  // Dialog: Join Project Dosen
  void _showJoinProjectDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _InputDialog(
        title: 'Join Project Dosen',
        icon: Icons.link_rounded,
        iconColor: Colors.teal,
        inputController: ctrl,
        hintText: 'Masukkan join_code dari dosen',
        submitLabel: 'Hubungkan',
        onSubmit: () async {
          if (ctrl.text.trim().isEmpty) return;
          Navigator.pop(ctx);
          final ok = await controller.joinProjectAndLink(
              ctrl.text.trim(), workspace.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok
                  ? 'Workspace berhasil dihubungkan ke project dosen!'
                  : controller.errorMessage ?? 'Gagal.'),
              backgroundColor: ok ? Colors.green : Colors.redAccent,
            ));
            if (ok) {
              await controller.loadWorkspaceData(workspace.id);
            }
          }
        },
      ),
      ),
    );
  }

  // Dialog: Ajukan Topik 
  void _showSubmitTopicDialog(BuildContext context) {
    final topicCtrl = TextEditingController(text: workspace.topicName);
    final descCtrl = TextEditingController(text: workspace.topicDescription);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.topic_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('Ajukan Topik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: topicCtrl,
              decoration: InputDecoration(
                  labelText: 'Nama Topik', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: 'Deskripsi Topik', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (topicCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx);
                      await controller.submitTopic(
                          workspace.id, topicCtrl.text.trim(), descCtrl.text.trim());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(controller.errorMessage == null
                              ? 'Topik berhasil diajukan!'
                              : controller.errorMessage!),
                          backgroundColor: controller.errorMessage == null
                              ? Colors.green
                              : Colors.redAccent,
                          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ));
                        if (controller.errorMessage == null) {
                          await controller.loadWorkspaceData(workspace.id);
                        }
                      }
                    },
                    child: const Text('Ajukan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (isDisabled)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? Colors.grey
                          : const Color(0xFF2D3142))),
            ],
          ),
        ),
      ),
    );
  }
}

// Member List

class _MemberList extends StatelessWidget {
  final WorkspaceDetailController controller;
  const _MemberList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final members = controller.workspaceMembers;
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Text('Belum ada anggota.',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: members.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: Text(m.fullName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold)),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (m.id == controller.leaderId) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                        ),
                        child: const Text(
                          'Ketua',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(m.email,
                    style: const TextStyle(fontSize: 12)),
              ),
              if (i < members.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Phase & Task List

class _PhaseTaskList extends StatelessWidget {
  final WorkspaceDetailController controller;
  final WorkspaceModel workspace; 

  const _PhaseTaskList({
    required this.controller,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil phase berdasarkan workspace.id
    final phases = controller.allPhases
        .where((p) => p.workspaceId == workspace.id)
        .toList();

    if (phases.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Text(
          'Belum ada phase. Ketua dapat menambahkan phase baru.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: phases.map((phase) {
        final tasks = controller.getTasksByPhase(phase.id);
        double progressDecimal = 0;
        if(tasks.isNotEmpty) {
          int totalProgress = tasks.fold(0, (sum, item) => sum + item.progress);
          progressDecimal = totalProgress / (tasks.length * 100);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: _PhaseStatusBadge(status: phase.status),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.phaseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressDecimal,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${phase.status} (${(progressDecimal * 100).toInt()}%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (phase.deadline != null) ...[
                    const SizedBox(height: 4),
                    _PhaseDeadlineLabel(deadline: phase.deadline!),
                  ],
                ],
              ),
            ),
            children: tasks.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text('Belum ada task di phase ini.',
                          style: TextStyle(color: Colors.grey)),
                    )
                  ]
                : tasks
                    .map((task) => ListTile(
                          dense: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider.value(value: controller),
                                    ChangeNotifierProvider(
                                      create: (context) {
                                        final ctrl = WorkspaceTaskController();
                                        ctrl.setOfflineManager(context.read<OfflineSubmissionManager>());
                                        return ctrl;
                                      },
                                    ),
                                  ],
                                  child: WorkspaceTaskView(
                                    workspace: workspace,
                                    task: task,
                                    phaseDeadline: phase.deadline,

                                  ),
                                ),
                              ),
                            ).then((_) {
                              controller.loadWorkspaceData(workspace.id);
                            });
                          },
                          leading: Icon(
                            task.isDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task.isDone ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          title: Text(task.taskDescription,
                              style: const TextStyle(fontSize: 13)),
                          subtitle: Text(
                            controller.getStudentName(task.studentId),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          trailing: _TaskStatusChip(status: task.status),
                        ))
                    .toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _PhaseStatusBadge extends StatelessWidget {
  final String status;
  const _PhaseStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'accepted':
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _PhaseDeadlineLabel extends StatelessWidget {
  final DateTime deadline;
  const _PhaseDeadlineLabel({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPassed = now.isAfter(deadline);
    final remaining = deadline.difference(now);
    final isUrgent = !isPassed && remaining.inHours < 24;

    final Color color;
    final IconData icon;
    if (isPassed) {
      color = Colors.red;
      icon = Icons.lock_clock;
    } else if (isUrgent) {
      color = Colors.orange;
      icon = Icons.warning_amber_rounded;
    } else {
      color = Colors.grey.shade600;
      icon = Icons.schedule;
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          isPassed
              ? 'Deadline terlewati: ${_formatDate(deadline)}'
              : 'Deadline: ${_formatDate(deadline)}',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isPassed || isUrgent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final localDt = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${localDt.day} ${months[localDt.month - 1]} ${localDt.year}, '
        '${localDt.hour.toString().padLeft(2, '0')}:'
        '${localDt.minute.toString().padLeft(2, '0')}';
  }
}

class _TaskStatusChip extends StatelessWidget {
  final String status;
  const _TaskStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (status) {
      case 'accepted':
      case 'approved':
        bg = Colors.green;
        break;
      case 'rejected':
        bg = Colors.red;
        break;
      default:
        bg = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(status,
          style: TextStyle(
              fontSize: 10, color: bg, fontWeight: FontWeight.bold)),
    );
  }
}

// Generic Input Dialog 

class _InputDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final TextEditingController inputController;
  final String hintText;
  final String submitLabel;
  final VoidCallback onSubmit;

  const _InputDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.inputController,
    required this.hintText,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: inputController,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onSubmit,
                  child: Text(submitLabel,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
