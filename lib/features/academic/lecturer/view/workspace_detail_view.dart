import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/workspace_model.dart';
import '../../../../controllers/lecturer/phase_approval_controller.dart';
import '../widgets/workspace_widget.dart';
import '../widgets/workspace_progress_widget.dart';

class WorkspaceDetailView extends StatefulWidget {
  final WorkspaceModel workspace;

  const WorkspaceDetailView({
    super.key,
    required this.workspace,
  });

  @override
  State<WorkspaceDetailView> createState() => _WorkspaceDetailViewState();
}

class _WorkspaceDetailViewState extends State<WorkspaceDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhaseApprovalController>().fetchPhases(widget.workspace.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, centerTitle: true,
          title: const Text("Detail Kelompok", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context, true)),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            WorkspaceHeaderWidget(initialWorkspace: widget.workspace),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab, indicator: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.indigo.shade700, unselectedLabelColor: Colors.grey.shade500, labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [Tab(text: "Progress Tugas"), Tab(text: "Anggota Tim")],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  WorkspaceProgressWidget(workspace: widget.workspace),
                  SingleChildScrollView(child: WorkspaceMembersWidget(workspace: widget.workspace)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}