import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/features/academic/student/controller/workspace_controller.dart';
import 'package:provider/provider.dart';


class WorkspaceJoinView extends StatefulWidget {
  const WorkspaceJoinView({super.key}); 

  @override
  State<WorkspaceJoinView> createState() => _WorkspaceJoinViewState();
}

class _WorkspaceJoinViewState extends State<WorkspaceJoinView> {
  late final TextEditingController idController;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinWorkspace() async {
    final workspaceId = idController.text.trim();
    if (workspaceId.isEmpty) {
      _showSnackBar("ID Kelompok tidak boleh kosong!", Colors.red);
      return; 
    }

    setState(() {
      _isLoading = true;
    });
    final workspaceController = Provider.of<WorkspaceController>(context, listen: false);
    final isSuccess = await workspaceController.joinWorkspaceById(workspaceId);

    if (!mounted) return; 
    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      _showSnackBar("Berhasil bergabung dengan kelompok!", Colors.green);
      Navigator.pop(context); 
    } else {
      _showSnackBar(workspaceController.errorMessage ?? "Terjadi kesalahan.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.pop(context),
        ),  
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(), 
            
            const SizedBox(height: 24),
            
            const Text("ID Kelompok", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 5),
            TextField(
              controller: idController,
              enabled: !_isLoading, 
              decoration: InputDecoration(
                hintText: "Tempel ID Kelompok di sini...", 
                hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
              ),
            ),

            const SizedBox(height: 42),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                onPressed: _isLoading ? null : _handleJoinWorkspace,
                child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        "Gabung Sekarang", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), 
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text("Gabung Kelompok", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(height: 6),
          const Text("Minta ID kelompok dari ketuamu lalu masukan di bawah.", style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}