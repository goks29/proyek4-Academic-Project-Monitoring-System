// lib/features/academic/lecturer/add_project_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Penting untuk fitur salin kode
import 'lecturer_controller.dart';

class AddProjectView extends StatefulWidget {
  const AddProjectView({super.key});

  @override
  State<AddProjectView> createState() => _AddProjectViewState();
}

class _AddProjectViewState extends State<AddProjectView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _infoController = TextEditingController();
  final _controller = LecturerController();
  
  bool _isLoading = false;
  String? _generatedCode;

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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("JUDUL TUGAS"),
              _buildTextField(_titleController, "Contoh: Sistem Administrasi"),
              const SizedBox(height: 20),
              
              _buildLabel("DESKRIPSI TUGAS"),
              _buildTextField(
                _descController,
                "Jelaskan gambaran umum tugas...",
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              
              _buildLabel("INFORMASI PENGUMPULAN AKHIR (OPSIONAL)"),
              _buildTextField(
                _infoController,
                "Misal: Kumpulkan link repository GitHub di sini...",
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submitData,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "BUAT TUGAS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // KOMPONEN KODE TUGAS (Muncul setelah data berhasil dibuat)
              if (_generatedCode != null) ...[
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "TUGAS BERHASIL DIBUAT!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generatedCode!,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                     ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Kode berhasil disalin!")),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text("SALIN KODE"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                          
                          // UBAH BAGIAN INI:
                          // Gunakan BorderSide, bukan Border.all
                          side: BorderSide(color: Colors.blue[700]!, width: 1), 
                          
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Kembali ke Beranda",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _submitData() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Deskripsi tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil fungsi di controller yang mengembalikan join code
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
}