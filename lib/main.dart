import 'package:aini_s_application1/api/firebase_api.dart';
import 'package:aini_s_application1/service/sensor_monitor.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/app_export.dart';
import 'firebase_options.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Awesome Notifications
  await _initAwesomeNotifications();

  // Inisialisasi Firestore Offline Mode
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true, // Aktifkan cache offline
  // );

  // Inisialisasi Local Notifications
  await initLocalNotifications();

  // Inisialisasi Firebase Messaging (FCM)
  await FirebaseApi().initNotifications();

  // Set Orientasi Portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  ThemeHelper().changeTheme('primary');

  runApp(MyApp());
}

// 🔹 Fungsi untuk inisialisasi Awesome Notifications
Future<void> _initAwesomeNotifications() async {
  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelGroupKey: 'critical_alerts',
        channelKey: 'critical_channel',
        channelName: 'Critical Alerts',
        channelDescription: 'Alerts for critical water conditions',
        importance: NotificationImportance.Max, // Notifikasi prioritas tinggi
        defaultColor: Colors.red,
        ledColor: Colors.red,
        playSound: true,
        enableVibration: true,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      ),
      NotificationChannelGroup(
        channelGroupKey: 'critical_alerts',
        channelGroupName: 'Critical Alerts Group',
      )
    ],
    debug: true,
  );
}

// 🔹 Inisialisasi local notifications
Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        print("Notification clicked: ${response.payload}");
      }
    },
  );
}

class MyApp extends StatelessWidget {
  MyApp() {
    SensorMonitor(); // Langsung mulai monitoring di constructor
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: theme,
          title: 'Karamba Warning',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initialRoute,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
