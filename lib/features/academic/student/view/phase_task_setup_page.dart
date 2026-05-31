import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:academic_project_monitoring_system/models/user_model.dart';
import '../controller/workspace_detail_controller.dart';

class _TaskEntry {
  String? studentId;
  final TextEditingController descCtrl;

  _TaskEntry({this.studentId}) : descCtrl = TextEditingController();

  void dispose() => descCtrl.dispose();

  bool get isValid => studentId != null && descCtrl.text.trim().isNotEmpty;
}

/// Satu fase dengan daftar task-nya (state lokal).
class _PhaseEntry {
  final TextEditingController nameCtrl;
  final TextEditingController orderCtrl;
  final List<_TaskEntry> tasks;
  DateTime? deadline;

  _PhaseEntry(int defaultOrder)
      : nameCtrl = TextEditingController(),
        orderCtrl = TextEditingController(text: '$defaultOrder'),
        tasks = [_TaskEntry()];

  void dispose() {
    nameCtrl.dispose();
    orderCtrl.dispose();
    for (final t in tasks) {
      t.dispose();
    }
  }

  bool get isValid => nameCtrl.text.trim().isNotEmpty;
}


class PhaseTaskSetupPage extends StatefulWidget {
  final String workspaceId;
  final List<UserModel> members;

  const PhaseTaskSetupPage({
    super.key,
    required this.workspaceId,
    required this.members,
  });

  @override
  State<PhaseTaskSetupPage> createState() => _PhaseTaskSetupPageState();
}

class _PhaseTaskSetupPageState extends State<PhaseTaskSetupPage> {
  final List<_PhaseEntry> _phases = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addPhase(); 
  }

  @override
  void dispose() {
    for (final p in _phases) {
      p.dispose();
    }
    super.dispose();
  }

  void _addPhase() {
    setState(() {
      _phases.add(_PhaseEntry(_phases.length + 1));
    });
  }

  void _removePhase(int index) {
    setState(() {
      _phases[index].dispose();
      _phases.removeAt(index);
      // Update sort order otomatis
      for (int i = 0; i < _phases.length; i++) {
        _phases[i].orderCtrl.text = '${i + 1}';
      }
    });
  }

  void _addTask(int phaseIndex) {
    setState(() {
      _phases[phaseIndex].tasks.add(_TaskEntry());
    });
  }

  void _removeTask(int phaseIndex, int taskIndex) {
    setState(() {
      _phases[phaseIndex].tasks[taskIndex].dispose();
      _phases[phaseIndex].tasks.removeAt(taskIndex);
    });
  }

  Future<void> _submit() async {
    for (int i = 0; i < _phases.length; i++) {
      if (!_phases[i].isValid) {
        _showError('Nama Phase ${i + 1} tidak boleh kosong.');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final phaseEntries = _phases.map((p) {
      final validTasks = p.tasks.where((t) => t.isValid).toList();
      return (
        phaseName: p.nameCtrl.text.trim(),
        sortOrder: int.tryParse(p.orderCtrl.text) ?? (_phases.indexOf(p) + 1),
        deadline: p.deadline,
        tasks: validTasks.map((t) => (
          studentId: t.studentId!,
          taskDescription: t.descCtrl.text.trim(),
        )).toList(),
      );
    }).toList();

    final ctrl = context.read<WorkspaceDetailController>();
    final ok = await ctrl.createPhasesWithTasks(widget.workspaceId, phaseEntries);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.pop(context, true); // true = ada perubahan
    } else {
      _showError(ctrl.errorMessage ?? 'Gagal menyimpan.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Atur Phase & Task',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Simpan Semua',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            color: Colors.blueAccent.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Task dengan deskripsi kosong atau tanpa anggota akan dilewati.',
                    style: TextStyle(
                      color: Colors.blueAccent.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List fase
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _phases.length + 1, // +1 untuk tombol tambah fase
              itemBuilder: (context, index) {
                if (index == _phases.length) {
                  // Tombol tambah fase di bagian bawah
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    child: OutlinedButton.icon(
                      onPressed: _addPhase,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Tambah Phase Baru'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        side: const BorderSide(color: Colors.blueAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }
                return _PhaseCard(
                  phaseIndex: index,
                  phaseEntry: _phases[index],
                  members: widget.members,
                  onAddTask: () => _addTask(index),
                  onRemoveTask: (tIndex) => _removeTask(index, tIndex),
                  onRemovePhase: _phases.length > 1 ? () => _removePhase(index) : null,
                  onChanged: () => setState(() {}),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Phase Card ───────────────────────

class _PhaseCard extends StatelessWidget {
  final int phaseIndex;
  final _PhaseEntry phaseEntry;
  final List<UserModel> members;
  final VoidCallback onAddTask;
  final void Function(int taskIndex) onRemoveTask;
  final VoidCallback? onRemovePhase;
  final VoidCallback onChanged;

  const _PhaseCard({
    required this.phaseIndex,
    required this.phaseEntry,
    required this.members,
    required this.onAddTask,
    required this.onRemoveTask,
    required this.onChanged,
    this.onRemovePhase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header fase
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A90E2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${phaseIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Phase',
                  style: TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                if (onRemovePhase != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Hapus Phase ini',
                    onPressed: onRemovePhase,
                  ),
              ],
            ),
          ),

          // Body: nama phase + tasks
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Phase
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: phaseEntry.nameCtrl,
                        onChanged: (_) => onChanged(),
                        decoration: InputDecoration(
                          labelText: 'Nama Phase',
                          hintText: 'Contoh: Analisis Kebutuhan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Sort order — auto tapi bisa diedit
                    SizedBox(
                      width: 72,
                      child: TextField(
                        controller: phaseEntry.orderCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: 'Urutan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Deadline picker
                _DeadlinePicker(
                  deadline: phaseEntry.deadline,
                  onChanged: (date) {
                    phaseEntry.deadline = date;
                    onChanged();
                  },
                ),

                const SizedBox(height: 16),

                // Label task
                Row(
                  children: [
                    const Text(
                      'Pembagian Tugas',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onAddTask,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),

                // Daftar tasks
                ...phaseEntry.tasks.asMap().entries.map((e) {
                  final tIndex = e.key;
                  final task = e.value;
                  return _TaskRow(
                    taskIndex: tIndex,
                    taskEntry: task,
                    members: members,
                    canRemove: phaseEntry.tasks.length > 1,
                    onRemove: () => onRemoveTask(tIndex),
                    onChanged: onChanged,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Task Row ───────────────────────

class _TaskRow extends StatelessWidget {
  final int taskIndex;
  final _TaskEntry taskEntry;
  final List<UserModel> members;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _TaskRow({
    required this.taskIndex,
    required this.taskEntry,
    required this.members,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${taskIndex + 1}',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tugas',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF555870),
                ),
              ),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Dropdown anggota
          DropdownButtonFormField<String>(
            value: taskEntry.studentId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Anggota',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            hint: const Text('Pilih anggota...', style: TextStyle(fontSize: 13)),
            items: members
                .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.fullName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) {
              taskEntry.studentId = v;
              onChanged();
            },
          ),

          const SizedBox(height: 8),

          // Deskripsi task
          TextField(
            controller: taskEntry.descCtrl,
            maxLines: 2,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Deskripsi Tugas',
              hintText: 'Apa yang harus dikerjakan?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Deadline Picker ───────────────────────

class _DeadlinePicker extends StatelessWidget {
  final DateTime? deadline;
  final ValueChanged<DateTime?> onChanged;

  const _DeadlinePicker({
    required this.deadline,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickDeadline(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event,
              color: deadline != null ? Colors.blueAccent : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                deadline != null
                    ? 'Deadline: ${_formatDate(deadline!)}'
                    : 'Set Deadline (opsional)',
                style: TextStyle(
                  color: deadline != null ? Colors.black87 : Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
            if (deadline != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: deadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih tanggal deadline',
    );

    if (date == null) return;

    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: deadline != null 
          ? TimeOfDay.fromDateTime(deadline!)
          : const TimeOfDay(hour: 23, minute: 59),
      helpText: 'Pilih jam deadline',
    );

    if (time == null) return;

    final combined = DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );
    onChanged(combined);
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
