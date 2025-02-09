import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    // Dapatkan token Firebase Cloud Messaging
    final fcmToken = await _firebaseMessaging.getToken();
    print("Token FCM: $fcmToken");

    // Menangani pesan ketika aplikasi berjalan di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "Notifikasi diterima di foreground: ${message.notification?.title}");
    });

    // Menangani pesan ketika aplikasi dalam background atau terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

// Handler untuk notifikasi di background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Notifikasi diterima di background: ${message.notification?.title}");
}
