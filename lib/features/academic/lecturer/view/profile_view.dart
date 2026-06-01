import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/login_controller.dart';
import '../../auth/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // AMBIL DATA DINAMIS DARI LoginController
    final user = context.watch<LoginController>().currentUser;
    
    final String name = user?.fullName ?? "Nama Dosen";
    final String email = user?.email ?? "Email tidak tersedia";
    final String role = user?.role ?? "lecturer";
    final String initials = _getInitials(name);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.indigo.shade100, width: 3)),
              child: CircleAvatar(radius: 50, backgroundColor: Colors.indigo, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(role.toUpperCase() == 'LECTURER' ? "Dosen Pengampu" : role, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: Icon(Icons.school_outlined, color: Colors.blue.shade600)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Peran Akun", style: TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 4), Text(role.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87))])),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          "Apakah kamu yakin ingin logout?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )
                            ),
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              final login = context.read<LoginController>();
                              await login.handleLogout();

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginView()),
                                  (route) => false
                                );
                              }
                            },
                            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    }
                  );
                },
                icon: Icon(Icons.logout, color: Colors.red.shade600), label: Text("LOGOUT", style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.red.shade200, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.red.shade50),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}