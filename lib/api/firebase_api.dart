import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();
    print('Token: $fCMToken');

    // Handle background message
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Inisialisasi Local Notification
    await _initLocalNotifications();

    // Listen notifikasi saat aplikasi berjalan (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        print(
            "Notifikasi diterima saat aplikasi terbuka: ${notification.title}");

        // Menampilkan notifikasi lokal agar muncul di foreground
        showLocalNotification(notification);
      }
    });

    // Handle notifikasi saat aplikasi dalam keadaan background atau ditutup
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOnOpen(message);
    });
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print("Notification clicked: ${response.payload}");
          // Tambahkan logika navigasi jika diperlukan
        }
      },
    );
  }

  void showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode, // ID unik
      notification.title,
      notification.body,
      notificationDetails,
    );
  }

  void _handleMessageOnOpen(RemoteMessage message) {
    print("Notifikasi dibuka: ${message.notification?.title}");
    // Tambahkan navigasi ke halaman tertentu jika perlu
  }
}

// Fungsi untuk menangani notifikasi saat aplikasi dalam background
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Notifikasi diterima di background:");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
}
