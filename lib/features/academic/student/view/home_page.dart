import 'package:academic_project_monitoring_system/features/academic/auth/login_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/auth/login_view.dart';
import 'package:academic_project_monitoring_system/features/academic/student/controller/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'workspace_home_view.dart';
import 'workspace_detail_view.dart';
import '../controller/workspace_detail_controller.dart';

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, ${loginController.currentUser?.fullName}",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

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
                  icon: const Icon(Icons.logout_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext sheetContext) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Logout",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Apakah kamu yakin ingin logout?",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(sheetContext),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(sheetContext);
                                        final login = context.read<LoginController>();
                                        await login.handleLogout();

                                        if (context.mounted) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            CupertinoPageRoute(builder: (context) => LoginView()),
                                            (route) => false
                                          );
                                        }
                                      },
                                      child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
        physics: const BouncingScrollPhysics(),
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
                        Text("${workspaceController.totalSelesai}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
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
                        Text("${workspaceController.totalTertunda}", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 25)),
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

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: workspaceController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : workspaceController.myWorkspaces.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "Belum ada project yang dibuat.",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workspaceController.myWorkspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = workspaceController.myWorkspaces[index];
                    final progressAvg = workspaceController.workspaceProgress[workspace.id] ?? 0.0;
                    final progressDecimal = progressAvg / 100.0;

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
                              CupertinoPageRoute(
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${workspace.teamName}",
                                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold ,fontSize: 20),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.topic_outlined, size: 14, color: Colors.blueAccent),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  workspace.topicName != null && workspace.topicName!.isNotEmpty 
                                                    ? workspace.topicName! 
                                                    : "Topik belum diajukan",
                                                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.folder_outlined, size: 14, color: Colors.orange),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  workspace.projectName != null && workspace.projectName!.isNotEmpty 
                                                    ? workspace.projectName! 
                                                    : "Belum terhubung ke project",
                                                  style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_right_rounded, color: Colors.grey)
                                  ],
                                ),
                                const SizedBox(height: 14),
                                
                                // Bar Progress
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Progres Keseluruhan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                                        const Spacer(),
                                        Text("${progressAvg.toInt()}%", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: progressDecimal, 
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
                )
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
            CupertinoPageRoute(
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

