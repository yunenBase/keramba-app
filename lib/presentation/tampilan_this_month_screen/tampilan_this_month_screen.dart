import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Function untuk mendapatkan nama hari dalam Bahasa Indonesia
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

class TampilanThisMonthScreen extends StatefulWidget {
  @override
  _TampilanThisMonthScreenState createState() =>
      _TampilanThisMonthScreenState();
}

class _TampilanThisMonthScreenState extends State<TampilanThisMonthScreen> {
  DateTime _selectedDate = DateTime.now();
  List<SalesData> _doData = [];
  List<SalesData> _phData = [];
  bool _isLoading = false; // Tambahkan indikator loading

  late ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePinching: true,
    zoomMode: ZoomMode.x,
    enablePanning: true,
    enableDoubleTapZooming: true,
  );

  @override
  void initState() {
    super.initState();

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
      enableDoubleTapZooming: true,
    );
    fetchData(_selectedDate); // Fetch data awal
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      fetchData(_selectedDate); // Fetch data sesuai tanggal yang dipilih
    });
  }

  Future<void> fetchData(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    String dateFormatted =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    String dayOfWeek = getDayOfWeek(date.weekday);

    if (dayOfWeek.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('history')
          .doc(dateFormatted)
          .collection(dayOfWeek)
          .get();

      List<SalesData> doData = [];
      List<SalesData> phData = [];
      DateTime? lastAddedTime;

      for (var doc in querySnapshot.docs) {
        String time = doc.id;
        String formattedTime = time.substring(0, 5);

        double doValue = doc['DO'] != null ? doc['DO'].toDouble() : 0;
        double phValue = doc['pH'] != null ? doc['pH'].toDouble() : 0;

        DateTime currentTime = DateTime.parse("$dateFormatted $time");

        if (lastAddedTime == null ||
            currentTime.difference(lastAddedTime).inMinutes >= 15) {
          doData.add(SalesData(formattedTime, doValue));
          phData.add(SalesData(formattedTime, phValue));

          lastAddedTime = currentTime;
        }
      }

      setState(() {
        _doData = doData;
        _phData = phData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Kalender
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            availableCalendarFormats: {CalendarFormat.month: 'Month'},
          ),

          SizedBox(height: 20),

          // Tampilkan tanggal yang dipilih
          Text(
            "Data ${getDayOfWeek(_selectedDate.weekday)[0].toUpperCase()}${getDayOfWeek(_selectedDate.weekday).substring(1)} ${_selectedDate.toLocal().toString().split(' ')[0]}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          // Loading Indicator
          if (_isLoading)
            CircularProgressIndicator()
          else if (_doData.isEmpty || _phData.isEmpty)
            Text("Tidak ada data tersedia.")
          else
            // LineChart
            Expanded(
              child: SfCartesianChart(
                zoomPanBehavior: _zoomPanBehavior,
                primaryXAxis: CategoryAxis(
                  autoScrollingDelta: 10,
                  autoScrollingMode: AutoScrollingMode.start,
                ),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: _doData,
                    xValueMapper: (SalesData sales, _) => sales.time,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    name: 'DO',
                    color: Colors.amber,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                  LineSeries<SalesData, String>(
                    dataSource: _phData,
                    xValueMapper: (SalesData sales, _) => sales.time,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    name: 'pH',
                    color: Colors.indigo,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Model Data untuk Chart
class SalesData {
  SalesData(this.time, this.value);
  final String time;
  final double value;
}
