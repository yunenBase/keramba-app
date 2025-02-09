import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Function to get the day of the week in Indonesian
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

class SalesChartWidget extends StatefulWidget {
  @override
  _SalesChartWidgetState createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, // Memungkinkan zoom dengan pinch
      zoomMode: ZoomMode.x, // Hanya zoom di sumbu X
      enablePanning: true, // Memungkinkan scroll horizontal
      enableDoubleTapZooming: true, // Zoom dengan double tap
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<SalesData>>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Data Available'));
        } else {
          var data1 = snapshot.data![0]; // DO data
          var data2 = snapshot.data![1]; // pH data

          return SfCartesianChart(
            zoomPanBehavior: _zoomPanBehavior, // Tambahkan fitur zoom & scroll
            primaryXAxis: CategoryAxis(
              autoScrollingDelta:
                  10, // Menampilkan 10 titik data sebelum bisa di-scroll
              autoScrollingMode:
                  AutoScrollingMode.start, // Mulai dari awal data
            ),
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<SalesData, String>>[
              LineSeries<SalesData, String>(
                dataSource: data1,
                xValueMapper: (SalesData sales, _) => sales.time,
                yValueMapper: (SalesData sales, _) => sales.value,
                name: 'DO',
                color: Colors.amber,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
              LineSeries<SalesData, String>(
                dataSource: data2,
                xValueMapper: (SalesData sales, _) => sales.time,
                yValueMapper: (SalesData sales, _) => sales.value,
                name: 'pH',
                color: Colors.indigo,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          );
        }
      },
    );
  }

  // Fetch data from Firestore dynamically based on current date and day
  Future<List<List<SalesData>>> fetchData() async {
    var currentDate = DateTime.now();
    var currentDateFormatted =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    // Get the current day of the week (in Indonesian)
    String dayOfWeek = getDayOfWeek(currentDate.weekday);
    if (dayOfWeek.isEmpty) {
      throw 'Error: Invalid day of week';
    }

    // Fetch data from Firestore
    var querySnapshot = await FirebaseFirestore.instance
        .collection('history')
        .doc(currentDateFormatted)
        .collection(dayOfWeek)
        .get();

    List<SalesData> doData = [];
    List<SalesData> phData = [];

    DateTime? lastAddedTime; // Menyimpan waktu terakhir yang dimasukkan

    for (var doc in querySnapshot.docs) {
      String time = doc.id; // Document ID (e.g., '07:30:00')

      // Ambil hanya HH:mm dari time (07:30)
      String formattedTime = time.substring(0, 5);

      double doValue = doc['DO'] != null ? doc['DO'].toDouble() : 0;
      double phValue = doc['pH'] != null ? doc['pH'].toDouble() : 0;

      // Konversi string waktu ke DateTime untuk perhitungan interval
      DateTime currentTime = DateTime.parse("${currentDateFormatted}T$time");

      // Pastikan hanya menyimpan data dengan interval minimal 15 menit
      if (lastAddedTime == null ||
          currentTime.difference(lastAddedTime).inMinutes >= 15) {
        doData.add(SalesData(formattedTime, doValue));
        phData.add(SalesData(formattedTime, phValue));

        lastAddedTime = currentTime; // Perbarui waktu terakhir yang disimpan
      }
    }

    return [doData, phData];
  }
}

// Model Data for Chart
class SalesData {
  SalesData(this.time, this.value);

  final String time;
  final double value;
}
