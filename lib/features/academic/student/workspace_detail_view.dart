import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_project_monitoring_system/models/workspace_model.dart';
import 'workspace_controller.dart';


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
      await context.read<WorkspaceController>().loadWorkspaceData(widget.workspace.id);
      if (mounted) _resolveLeaderStatus();
    });
  }

  void _resolveLeaderStatus() {
    if (!mounted) return;
    final ctrl = context.read<WorkspaceController>();
    setState(() {
      _isLeader = ctrl.isCurrentUserLeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WorkspaceController>();
    final ws = widget.workspace;

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
      body: ctrl.isLoading
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
                    _PhaseTaskList(controller: ctrl, workspaceId: ws.id),
                    const SizedBox(height: 32),
                  ],
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
                        const SnackBar(
                            content: Text('ID kelompok disalin!'),
                            backgroundColor: Colors.green),
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
              text: ws.projectId.isEmpty
                  ? 'Belum terhubung ke project dosen'
                  : 'Project: ${ws.projectName ?? ws.projectId}'),
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
  final WorkspaceController controller;
  final String currentUserId;

  const _LeaderActionsGrid({
    required this.workspace,
    required this.controller,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyLinked = workspace.projectId.isNotEmpty;

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
    // final result = await Navigator.push<bool>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => PhaseTaskSetupPage(
    //       workspaceId: workspace.id,
    //       members: controller.workspaceMembers,
    //     ),
    //   ),
    // );
    // // Jika ada data baru tersimpan, refresh detail
    // if (result == true && context.mounted) {
    //   await controller.loadWorkspaceData(workspace.id);
    // }
  }

  // Dialog: Join Project Dosen
  void _showJoinProjectDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => _InputDialog(
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
          }
        },
      ),
    );
  }

  // Dialog: Ajukan Topik 
  void _showSubmitTopicDialog(BuildContext context) {
    final topicCtrl = TextEditingController(text: workspace.topicName);
    final descCtrl = TextEditingController(text: workspace.topicDescription);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.topic_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Ajukan Topik', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nama Topik', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Deskripsi Topik', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
                ));
              }
            },
            child: const Text('Ajukan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Dialog: Tambah Phase 
  void _showCreatePhaseDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final orderCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.playlist_add_rounded, color: Colors.purple),
            SizedBox(width: 8),
            Text('Tambah Phase', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nama Phase', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: orderCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Urutan (sort order)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final order = int.tryParse(orderCtrl.text) ?? 1;
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await controller.createPhase(workspace.id, name, order);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(controller.errorMessage == null
                      ? 'Phase berhasil diajukan ke dosen!'
                      : controller.errorMessage!),
                  backgroundColor: controller.errorMessage == null
                      ? Colors.green
                      : Colors.redAccent,
                ));
              }
            },
            child:
                const Text('Ajukan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Dialog: Alokasi Task ──
  void _showCreateTaskDialog(BuildContext context) {
    final members = controller.workspaceMembers;
    String? selectedStudentId = members.isNotEmpty ? members.first.id : null;
    final taskCtrl = TextEditingController();

    if (controller.allPhases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Buat phase terlebih dahulu sebelum mengalokasikan task.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.assignment_ind_rounded, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Alokasi Task',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown pilih phase
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Phase', border: OutlineInputBorder()),
                  items: controller.allPhases
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.phaseName,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (_) {},
                  value: controller.allPhases.first.id,
                ),
                const SizedBox(height: 12),
                // Dropdown pilih anggota
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Anggota', border: OutlineInputBorder()),
                  value: selectedStudentId,
                  items: members
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.fullName,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedStudentId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: taskCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Deskripsi Task',
                      border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent),
              onPressed: () async {
                if (taskCtrl.text.trim().isEmpty ||
                    selectedStudentId == null) return;
                final phaseId = controller.allPhases.first.id;
                Navigator.pop(ctx);
                await controller.createTaskAllocation(
                    phaseId, selectedStudentId!, taskCtrl.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(controller.errorMessage == null
                        ? 'Task berhasil dialokasikan!'
                        : controller.errorMessage!),
                    backgroundColor: controller.errorMessage == null
                        ? Colors.green
                        : Colors.redAccent,
                  ));
                }
              },
              child: const Text('Simpan',
                  style: TextStyle(color: Colors.white)),
            ),
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
  final WorkspaceController controller;
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
                title: Text(m.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
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
  final WorkspaceController controller;
  final String workspaceId;

  const _PhaseTaskList(
      {required this.controller, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    final phases = controller.allPhases
        .where((p) => p.workspaceId == workspaceId)
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
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: _PhaseStatusBadge(status: phase.status),
            title: Text(phase.phaseName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Status: ${phase.status}',
                style: const TextStyle(fontSize: 12)),
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

class _TaskStatusChip extends StatelessWidget {
  final String status;
  const _TaskStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (status) {
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: TextField(
        controller: inputController,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: iconColor),
          onPressed: onSubmit,
          child: Text(submitLabel,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}