// lib/features/academic/lecturer/add_project_view.dart
import 'package:flutter/material.dart';
import '../lecturer_controller.dart';

// Import Widget yang sudah dibuat
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
  
  // Jika kamu menggunakan arsitektur Singleton yang kita buat sebelumnya
  // final _controller = globalLecturerController; 
  // Jika masih menggunakan controller mandiri:
  final _controller = LecturerController(); 
  
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Deskripsi tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final resultLabel = await _controller.createProject(
      _titleController.text,
      _descController.text,
      _infoController.text,
    );

    setState(() {
      _isLoading = false;
      _generatedCode = resultLabel;
    });
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
              // Menggunakan Widget Terpisah
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

              // TOMBOL UTAMA
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

              // MUNCUL JIKA KODE BERHASIL DIGENERATE
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