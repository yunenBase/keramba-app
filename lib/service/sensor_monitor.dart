import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SensorMonitor {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SensorMonitor() {
    _initializeNotifications();
    _startListeningToFirestore();
  }

  void _initializeNotifications() async {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);

    // 🔹 Minta izin untuk notifikasi
    var androidDetails = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    print("📌 Izin Notifikasi: $androidDetails");
  }

  void _showNotification(String title, String message) async {
    var androidDetails = const AndroidNotificationDetails(
      'warning_channel',
      'Peringatan Sensor',
      importance: Importance.high,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, message, notificationDetails);
  }

  void _startListeningToFirestore() {
    String formattedDate = _getCurrentDate();
    String dayOfWeek = _getDayOfWeek(DateTime.now().weekday);

    print(
        "🗂️ Mendengarkan Firestore pada path: history/$formattedDate/$dayOfWeek");

    FirebaseFirestore.instance
        .collection('history')
        .doc(formattedDate)
        .collection(dayOfWeek)
        .snapshots()
        .listen((querySnapshot) {
      print(
          "🔥 Data Firestore berubah! Jumlah dokumen: ${querySnapshot.docs.length}");

      for (var doc in querySnapshot.docs) {
        double doLevel = (doc['DO'] as num).toDouble();
        double pHLevel = (doc['pH'] as num).toDouble();

        print("🔍 Data sensor: DO=$doLevel, pH=$pHLevel");

        if (doLevel > 5 && pHLevel <= 6) {
          print(
              "⚠️ Peringatan: pH tidak sesuai standar, air dalam keadaan asam");
          _showNotification(
              "Peringatan", "pH tidak sesuai standar, air dalam keadaan asam");
        } else if (doLevel <= 5 && pHLevel > 6) {
          print(
              "⚠️ Peringatan: Konsentrasi oksigen tidak sesuai standar, kadar oksigen mengalami penurunan");
          _showNotification("Peringatan",
              "Konsentrasi oksigen tidak sesuai standar, kadar oksigen mengalami penurunan");
        } else if (pHLevel <= 6 && doLevel <= 5) {
          print(
              "🚨 Evakuasi Ikan: Segera evakuasi ikan, terjadi tubo balerang!");
          _showNotification(
              "Evakuasi Ikan", "Segera evakuasi ikan, terjadi tubo balerang!");
        }
      }
    }, onError: (error) {
      print("❌ ERROR Firestore: $error");
    });
  }

  String _getCurrentDate() {
    var now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getDayOfWeek(int weekday) {
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
