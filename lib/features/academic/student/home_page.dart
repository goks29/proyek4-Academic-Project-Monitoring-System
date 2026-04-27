import 'package:academic_project_monitoring_system/features/academic/auth/login_controller.dart';
import 'package:academic_project_monitoring_system/features/academic/auth/login_view.dart';
import 'package:academic_project_monitoring_system/features/academic/student/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workspace_view.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final loginController = context.watch<LoginController>();
    final workspaceController = context.watch<WorkspaceController>();

    return Scaffold(
      //header
      appBar: AppBar(
        title: 
        Column (
          children: [
            Row(
              children: [
                //header : bagian nama (kiri)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, ${loginController.currentUser?.fullName}",
                      style: TextStyle(
                        color: Colors.black,
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

                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white,),
                ),

                // Logout
                /// Belom ada dialog konfirmasi ya gok
                IconButton(
                  icon: Icon(Icons.logout_outlined),
                  onPressed: () async {
                    final loginController = context.read<LoginController>();

                    await loginController.handleLogout();

                    if (context.mounted){
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                        (route) => false
                      );
                    }
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
              "Detail Tugas",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              )
            ),
            const SizedBox(height: 6),

            //List Tubes
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //nama dan icon panah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${workspaceController.myWorkspaces}",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ,fontSize: 23)
                          ),
                          Text(
                            "Kelompok 7",
                            style: TextStyle(color: Colors.black, fontSize: 15)
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.arrow_right_rounded, color: Colors.grey,)
                    ],
                  ),
                  const SizedBox(height: 14),
                  //bar progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //text dan persen
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Progres Keseluruhan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                          Spacer(),
                          Text("90%", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))
                        ],
                      ),
                      const SizedBox(height: 8),
                      //progres bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.90, 
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          minHeight: 8, 
                        ),
                      ),
                      const SizedBox(height: 16),

                      //line
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),

                      //Update
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[300]),
                          const SizedBox(width: 6),
                          Text(
                            "Di Update 2 jam yang lalu",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
              builder: (context) => WorkspaceView(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

