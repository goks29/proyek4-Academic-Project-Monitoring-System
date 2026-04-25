import 'package:flutter/material.dart';

class StudentView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
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
                      "Halo, Faliq",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      "241511017",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    )
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
                      SizedBox(width: 6),
                      
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
                SizedBox(width: 8),

                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white,),
                ),
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
                        SizedBox(height: 6),
                        Text("17", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                      ],
                    )                  
                  ),
                ),
                SizedBox(width: 10),

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
                        SizedBox(height: 6),
                        Text("2", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 25)),
                      ],
                    )                  
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              "Detail Team",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              )
            ),
            SizedBox(height: 6),

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
                            "Nama Mata Kuliah",
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
                  SizedBox(height: 14),
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
                      SizedBox(height: 8),
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
                      SizedBox(height: 16),

                      //line
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 8),

                      //Update
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[300]),
                          SizedBox(width: 6),
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
    );
  }
}

