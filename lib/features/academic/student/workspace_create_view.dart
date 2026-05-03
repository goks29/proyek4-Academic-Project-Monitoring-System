import 'package:flutter/material.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_controller.dart';
import 'package:provider/provider.dart';
// import 'workspace_controller.dart'; 

class WorkspaceCreateView extends StatefulWidget {
  @override
  State<WorkspaceCreateView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceCreateView> {
  late final TextEditingController teamNameController;
  late final TextEditingController topicNameController;
  late final TextEditingController topicDescriptionController;

  @override
  void initState() {
    super.initState();
    teamNameController = TextEditingController();
    topicNameController = TextEditingController();
    topicDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    teamNameController.dispose();
    topicNameController.dispose();
    topicDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceController = context.watch<WorkspaceController>();
    
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    //body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity, 
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity, 
                padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0), 
                decoration: BoxDecoration(
                  color: Colors.blueAccent, 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Ikon Toko/Workspace
                    const Icon(
                      Icons.storefront, 
                      color: Colors.white, 
                      size: 48
                    ),
                    const SizedBox(height: 16),       
                    // Teks Kecil
                    Text(
                      "Tambah Kelompok",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 1.2, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),                   
                    // Teks Judul Besar
                    const Text(
                      "Masukan Detail Kelompok Tubes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              //form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama Tim", style: TextStyle(color: Colors.black,fontSize: 15, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: teamNameController,
                    decoration: InputDecoration(
                      labelText: "",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  ),
                  const SizedBox(height: 5),

                  Text("Topik", style: TextStyle(color: Colors.black,fontSize: 15, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: topicNameController,
                    decoration: InputDecoration(
                      labelText: "",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  ),
                  const SizedBox(height: 5),

                  Text("Deskripsi", style: TextStyle(color: Colors.black,fontSize: 15, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: topicDescriptionController,
                    decoration: InputDecoration(
                      labelText: "",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: workspaceController.isLoading
                        ? null
                        : () async {
                          await context.read<WorkspaceController>().createWorkspace(               
                            teamName: teamNameController.text,
                            topic: topicNameController.text,
                            description: topicDescriptionController.text,
                          );

                          if (context.mounted) {
                            final errorMsg = context.read<WorkspaceController>().errorMessage;

                            if (errorMsg != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Data Berhasil Dibuat!"), backgroundColor: Colors.green),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                      child: workspaceController.isLoading
                        ? const SizedBox(
                            height: 24, width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                          )
                        : const Text(
                          "Tambah Kelompok",
                          style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}