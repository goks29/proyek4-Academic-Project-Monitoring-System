import 'package:academic_project_monitoring_system/features/academic/auth/login_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/auth/login_view.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workspace_home_view.dart';
import 'workspace_detail_view.dart';
import 'workspace_detail_controller.dart';

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<WorkspaceController>().fetchMyWorkspaces()
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginController = context.watch<LoginController>();
    final workspaceController = context.watch<WorkspaceController>();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
      //header
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
        title: 
        Column (
          children: [
            Row(
              children: [
                //Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white,),
                ),
                const SizedBox(width: 8),
                //header : bagian nama (kiri)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, ${loginController.currentUser?.fullName}",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
        
                Spacer(),

                //header : bagian indikator dan gambar profil kosong (kanan)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      
                      Text(
                        "ONLINE",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Logout
                IconButton(
                  icon: Icon(Icons.logout_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(20),
                          ),
                          title: const Text(
                            "Apakah kamu yakin ingin logout?", style: TextStyle(fontWeight: FontWeight.bold),
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
                                  borderRadius: BorderRadiusGeometry.circular(8),
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
                  }
                )
              ],
            ),
            //seach bar
          ],
        )
      ),
      //body
      body: SingleChildScrollView(
        padding : EdgeInsets.all(16.0),
        child : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            //body : 2 buah kotak
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding : EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tugas yang sudah selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 6),
                        Text("17", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                      ],
                    )                  
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding : EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border : Border.all(
                        color: Colors.grey,
                        width: 0.5,
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tugas yang tertunda", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 6),
                        Text("2", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 25)),
                      ],
                    )                  
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Detail Tugas Besar",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              )
            ),
            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                if (workspaceController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (workspaceController.myWorkspaces.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsetsGeometry.all(20.0),
                      child: Text(
                        "Belum ada project yang dibuat.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workspaceController.myWorkspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaceController.myWorkspaces[index];

                    //List Tubes
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.5,
                        )
                      ),
                      child: Material(
                        color: Colors.transparent, 
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15), 
                          onTap: () {
                            // Navigasi ke WorkspaceDetailView saat diklik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (_) => WorkspaceDetailController(),
                                  child: WorkspaceDetailView(workspace: workspace),
                                ),
                              ),
                            ).then((_) {
                              context.read<WorkspaceController>().fetchMyWorkspaces();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama dan Icon Panah
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${workspace.teamName}",
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold ,fontSize: 20)
                                        ),
                                        Text(
                                          "Kelompok ${workspace.topicName}",
                                          style: const TextStyle(color: Colors.black, fontSize: 13),
                                        ),
                                        Text(
                                          "Tugas ${workspace.projectName}",
                                          style: const TextStyle(color: Colors.black, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_right_rounded, color: Colors.grey)
                                  ],
                                ),
                                const SizedBox(height: 14),
                                
                                // Bar Progress (nanti Di Fix)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("Progres Keseluruhan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                                        Spacer(),
                                        Text("90%", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: 0.90, 
                                        backgroundColor: Colors.grey[200],
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                        minHeight: 8, 
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: Colors.grey[300]),
                                    const SizedBox(height: 8),
 
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.access_time, color: Colors.grey[300]),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "Baru Saja Di Update",
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkspaceHomeView(),
            ),
          ).then((_) {
            context.read<WorkspaceController>().fetchMyWorkspaces();
          });
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

