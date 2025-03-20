import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LatestSensorData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getLatestSensorData(), // Stream dari Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Data Available"));
        }

        // Ambil data terbaru
        var latestDoc = snapshot.data!.docs.last;
        double latestDO = latestDoc['DO']?.toDouble() ?? 0.0;
        double latestPH = latestDoc['pH']?.toDouble() ?? 0.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text("DO",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("$latestDO", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(width: 20), // Jarak antar kolom
            Column(
              children: [
                Text("pH",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("$latestPH", style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mendapatkan stream data terbaru dari Firestore
  Stream<QuerySnapshot> getLatestSensorData() {
    var currentDate = DateTime.now();
    var currentDateFormatted =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    String dayOfWeek = getDayOfWeek(currentDate.weekday);
    if (dayOfWeek.isEmpty) throw 'Error: Invalid day of week';

    return FirebaseFirestore.instance
        .collection('history')
        .doc(currentDateFormatted)
        .collection(dayOfWeek)
        .orderBy(FieldPath.documentId,
            descending: true) // 🔥 Urutkan berdasarkan ID (jam terbaru dulu)
        .limit(1) // 🔥 Ambil hanya 1 dokumen terbaru
        .snapshots(includeMetadataChanges: true);
  }

  // Fungsi untuk mendapatkan nama hari dalam bahasa Indonesia
  String getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'senin';
      case 2:
        return 'selasa';
      case 3:
        return 'rabu';
      case 4:
        return 'kamis';
      case 5:
        return 'jumat';
      case 6:
        return 'sabtu';
      case 7:
        return 'minggu';
      default:
        return '';
    }
  }
}
