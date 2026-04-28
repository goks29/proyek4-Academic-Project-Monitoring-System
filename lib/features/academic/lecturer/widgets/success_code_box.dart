// lib/features/academic/lecturer/widgets/success_code_box.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuccessCodeBox extends StatelessWidget {
  final String generatedCode;
  final VoidCallback onBackToHome;

  const SuccessCodeBox({
    super.key,
    required this.generatedCode,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            generatedCode,
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
              Clipboard.setData(ClipboardData(text: generatedCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Kode berhasil disalin!")),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text("SALIN KODE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!, width: 1), 
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onBackToHome,
            child: const Text(
              "Kembali ke Beranda",
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}