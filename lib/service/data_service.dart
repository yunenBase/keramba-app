import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil data rata-rata bulanan
  Future<MonthlyData?> getMonthlyData(int month, int year) async {
    List<double> weeklyDoAverages = [];
    List<double> weeklyPhAverages = [];

    List<WeeklyData> weeklyData =
        await getWeeklyData(month, year); // Kirim bulan & tahun

    for (var week in weeklyData) {
      weeklyDoAverages.add(week.doAverage);
      weeklyPhAverages.add(week.phAverage);
    }

    if (weeklyDoAverages.isNotEmpty && weeklyPhAverages.isNotEmpty) {
      return MonthlyData(
        _calculateAverage(weeklyDoAverages),
        _calculateAverage(weeklyPhAverages),
      );
    }
    return null; // Jika tidak ada data
  }

  /// Ambil data rata-rata mingguan
  Future<List<WeeklyData>> getWeeklyData(int month, int year) async {
    List<WeeklyData> weeklyData = [];
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    int daysInMonth =
        DateTime(year, month + 1, 0).day; // Jumlah hari dalam bulan

    for (int week = 0; week < (daysInMonth / 7).ceil(); week++) {
      DateTime startOfWeek = firstDayOfMonth.add(Duration(days: week * 7));

      List<double> dailyDoAverages = [];
      List<double> dailyPhAverages = [];

      for (int day = 0; day < 7; day++) {
        DateTime currentDate = startOfWeek.add(Duration(days: day));
        if (currentDate.month != month) break; // Hindari keluar dari bulan

        var dailyData = await _fetchDailyAverages(currentDate);
        if (dailyData != null) {
          dailyDoAverages.add(dailyData.doAverage);
          dailyPhAverages.add(dailyData.phAverage);
        }
      }

      if (dailyDoAverages.isNotEmpty && dailyPhAverages.isNotEmpty) {
        weeklyData.add(WeeklyData(
          _calculateAverage(dailyDoAverages),
          _calculateAverage(dailyPhAverages),
        ));
      }
    }
    return weeklyData;
  }

  /// Ambil data rata-rata harian untuk minggu tertentu
  Future<List<DailyData>> getDailyData(int weekNumber) async {
    List<DailyData> dailyDataList = [];
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfWeek =
        firstDayOfMonth.add(Duration(days: (weekNumber - 1) * 7));

    for (int day = 0; day < 7; day++) {
      DateTime currentDate = startOfWeek.add(Duration(days: day));
      var dailyData = await _fetchDailyAverages(currentDate);
      dailyDataList
          .add(dailyData ?? DailyData(0, 0)); // Default jika tidak ada data
    }

    return dailyDataList;
  }

  /// Ambil rata-rata DO dan pH harian dari Firestore
  Future<DailyData?> _fetchDailyAverages(DateTime date) async {
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    String dayOfWeek = getDayOfWeek(date.weekday);

    var querySnapshot = await _firestore
        .collection('history')
        .doc(formattedDate)
        .collection(dayOfWeek)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    double dailyDoSum = 0, dailyPhSum = 0;
    for (var doc in querySnapshot.docs) {
      dailyDoSum += doc['DO'];
      dailyPhSum += doc['pH'];
    }

    return DailyData(dailyDoSum / querySnapshot.docs.length,
        dailyPhSum / querySnapshot.docs.length);
  }

  /// Hitung rata-rata dari list angka
  double _calculateAverage(List<double> values) {
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Konversi angka ke nama hari
  String getDayOfWeek(int weekday) {
    const days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu'
    ];
    return days[weekday - 1];
  }
}

/// Model untuk data rata-rata bulanan
class MonthlyData {
  final double doAverage;
  final double phAverage;

  MonthlyData(this.doAverage, this.phAverage);

  String get doAverageFormatted => doAverage.toStringAsFixed(2);
  String get phAverageFormatted => phAverage.toStringAsFixed(2);
}

/// Model untuk data rata-rata mingguan
class WeeklyData {
  final double doAverage;
  final double phAverage;

  WeeklyData(this.doAverage, this.phAverage);

  String get doAverageFormatted => doAverage.toStringAsFixed(2);
  String get phAverageFormatted => phAverage.toStringAsFixed(2);
}

/// Model untuk data rata-rata harian
class DailyData {
  final double doAverage;
  final double phAverage;

  DailyData(this.doAverage, this.phAverage);
}
