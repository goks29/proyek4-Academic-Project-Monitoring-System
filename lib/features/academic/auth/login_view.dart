import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/student/student_view.dart';

class LoginView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginController = context.watch<LoginController>();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("APMS Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 24),
            if (loginController.error != null) 
              Text(loginController.error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 24),
            loginController.isLoading 
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    bool success = await loginController.handleLogin(
                      emailController.text, 
                      passwordController.text
                    );
                    if (success) {
                      final user = loginController.currentUser;

                      if (user != null) {
                        switch (user.role) {
                          case 'student':
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => StudentView()),
                            );
                            break;
                          case 'lecturer':
                            // Bagian dosen janlup diisi woi
                            break;
                          default:
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Pengguna tidak dikenali")),
                            );
                        }
                      }
                    }
                  },
                  child: Text("Login"),
                ),
          ],
        ),
      ),
    );
  }
}