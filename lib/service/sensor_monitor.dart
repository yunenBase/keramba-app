import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

void onBackgroundNotificationResponse(NotificationResponse response) {
  SensorMonitor.instance
      ._stopAlarm(); // 🔇 Hentikan alarm saat notifikasi dihapus
}

class SensorMonitor {
  static final SensorMonitor instance = SensorMonitor._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _player = AudioPlayer();

  SensorMonitor._internal();

  bool _isAlarmPlaying = false;
  bool _isAlertActive = false;
  String? _lastDocumentID;
  String _lastWarningType = '';

  SensorMonitor() {
    _initializeNotifications();
    _listenToFirestore();
  }

  void _initializeNotifications() async {
    await _notificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onDidReceiveNotificationResponse: (response) {
      if (response.actionId == 'STOP_ALARM') _stopAlarm();
    },
        onDidReceiveBackgroundNotificationResponse:
            onBackgroundNotificationResponse);
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _showNotification(String title, String message,
      {bool withAlarm = false, int id = 0}) async {
    if (_lastWarningType == message) return; // Hindari notifikasi duplikat
    _lastWarningType = message;

    var androidDetails = AndroidNotificationDetails(
      'warning_channel',
      'Peringatan Sensor',
      importance: Importance.high,
      priority: Priority.high,
      actions: withAlarm
          ? [
              const AndroidNotificationAction('STOP_ALARM', 'Matikan Alarm',
                  showsUserInterface: true),
            ]
          : [],
      ongoing: withAlarm,
      autoCancel: !withAlarm,
      fullScreenIntent: withAlarm,
    );

    await _notificationsPlugin.show(
        id, title, message, NotificationDetails(android: androidDetails));
    if (withAlarm) _playAlarm();
  }

  void _playAlarm() async {
    if (_isAlarmPlaying) return;
    _isAlarmPlaying = true;
    await _player.play(AssetSource('sounds/alarm.wav'));
    Future.delayed(Duration(seconds: 10), _stopAlarm);
  }

  void _stopAlarm() async {
    await _player.stop();
    _isAlarmPlaying = false;
    _isAlertActive = false;
    _notificationsPlugin.cancelAll();
  }

  void _listenToFirestore() {
    String date = _getCurrentDate();
    String day = _getDayOfWeek(DateTime.now().weekday);

    FirebaseFirestore.instance
        .collection('history')
        .doc(date)
        .collection(day)
        .orderBy(FieldPath.documentId, descending: true)
        // .orderBy('__name__', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      var doc = snapshot.docs.first;
      if (_lastDocumentID == doc.id) return;
      _lastDocumentID = doc.id;

      double doLevel = (doc['DO'] as num).toDouble();
      double pHLevel = (doc['pH'] as num).toDouble();

      if (pHLevel <= 6 && doLevel <= 5 && !_isAlertActive) {
        _showNotification("Evakuasi Ikan",
            "Nilai pH : $pHLevel, DO : $doLevel, terjadi tubo balerang!",
            withAlarm: true, id: 1);
        _isAlertActive = true;
      } else if (pHLevel <= 6) {
        _showNotification("Nilai pH Dibawah Standar",
            "Nilai pH : $pHLevel, DO : $doLevel, air dalam keadaan asam",
            id: 2);
      } else if (doLevel <= 5) {
        _showNotification("Nilai DO Dibawah Standar",
            "Nilai pH : $pHLevel, DO : $doLevel, Konsentrasi oksigen menurun!",
            id: 3);
      } else {
        _stopAlarm();
      }
    }, onError: (error) => print("❌ ERROR Firestore: $error"));
  }

  String _getCurrentDate() {
    var now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getDayOfWeek(int weekday) {
    return [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu'
    ][weekday - 1];
  }
}
