// lib/features/academic/lecturer/view/add_project_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../controllers/lecturer/project_controller.dart'; 

// Import Widget
import '../widgets/project_input_field.dart';
import '../widgets/success_code_box.dart';

class AddProjectView extends StatefulWidget {
  const AddProjectView({super.key});

  @override
  State<AddProjectView> createState() => _AddProjectViewState();
}

class _AddProjectViewState extends State<AddProjectView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _infoController = TextEditingController();

  bool _isLoading = false;
  String? _generatedCode;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  void _submitData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul dan Deskripsi tidak boleh kosong")));
      return;
    }

    // Hapus ID hardcode, gunakan Empty String ("")
    final lecturerId = Supabase.instance.client.auth.currentUser?.id ?? "";
    if (lecturerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akses ditolak: User belum login.")));
      return;
    }

    setState(() => _isLoading = true);

    // Dapatkan instance ProjectController
    final projectCtrl = context.read<ProjectController>();

    // Gunakan fungsi createProject
    final success = await projectCtrl.createProject(
      lecturerId,
      _titleController.text,
      _descController.text,
      _infoController.text,
    );

    if (success) {
      final newProject = projectCtrl.projects.last;

      setState(() {
        _isLoading = false;
        _generatedCode = newProject.joinCode;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(projectCtrl.errorMessage ?? "Gagal membuat proyek"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Buat Tugas Besar Baru",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProjectInputField(
                label: "JUDUL TUGAS",
                hint: "Contoh: Sistem Administrasi",
                controller: _titleController,
              ),
              const SizedBox(height: 20),
              
              ProjectInputField(
                label: "DESKRIPSI TUGAS",
                hint: "Jelaskan gambaran umum tugas...",
                controller: _descController,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              
              ProjectInputField(
                label: "INFORMASI PENGUMPULAN AKHIR (OPSIONAL)",
                hint: "Misal: Kumpulkan link repository GitHub di sini...",
                controller: _infoController,
                maxLines: 2,
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submitData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "BUAT TUGAS",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                ),
              ),

              if (_generatedCode != null) ...[
                const SizedBox(height: 30),
                SuccessCodeBox(
                  generatedCode: _generatedCode!,
                  onBackToHome: () => Navigator.pop(context, true),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}