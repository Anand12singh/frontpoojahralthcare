import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:poojaheakthcare/screens/login_screen.dart';
import 'package:poojaheakthcare/screens/patient_info_screen.dart';
import 'package:poojaheakthcare/screens/splash_screen.dart';
import 'package:poojaheakthcare/utils/colors.dart';
import 'constants/global_variable.dart';
import 'firebase_options.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Background notification handler (Mobile Only)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log("📩 Background Message Received: ${message.messageId}");
  await NotificationService.showNotification(message);
}

// Local Notifications Plugin (Mobile Only)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register Firebase listeners EARLY
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log("📩 Foreground Message Received");
    NotificationService.showNotification(message);
  });

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize notification service
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pooja Healthcare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: false,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.button,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/patientInfo': (context) => const PatientInfoScreen(),
      },
      navigatorKey: NotificationService.navigatorKey,
    );
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await _initializeWebNotifications();
      } else {
        await _requestPermissions();
        await _setupTokenHandling();
        await _setupMessageHandlers();
        await _initializeLocalNotifications();
      }
    } catch (e) {
      log("🚨 Notification Initialization Error: $e");
    }
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    log('🔔 Notification Permission Status: ${settings.authorizationStatus}');
  }

  static Future<String?> _setupTokenHandling() async {
    String? token = await _messaging.getToken();
    log("🔑 FCM Token: $token");
    Global.fcm_token = token;

    _messaging.onTokenRefresh.listen((newToken) {
      log("🔄 New FCM Token: $newToken");
      // Send to your server
    });

    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      Global.device_info = "ios";

      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      Global.device_info = "android";

      var androidDeviceInfo = await deviceInfo.androidInfo;
      // _storage.writeSecureData(
      //     key: 'deviceId', value: '${androidDeviceInfo.id}');

      return androidDeviceInfo.id;
    }
  }

  static Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground Message Received");
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("📲 App Opened via Notification");
      _handleNotification(message);
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotification(initialMessage);
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        log("📩 Notification Tapped: ${details.payload}");
      },
    );
  }

  static Future<void> _initializeWebNotifications() async {
    try {
      String? token = await _messaging.getToken();
      log("🌐 Web FCM Token: $token");
      Global.fcm_token = token;
      Global.device_info = "web";

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("🌐 Web Foreground Message Received: ${message.notification?.title}");
        _showWebSnackbar(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? 'You have a new message',
        );
      });
    } catch (e) {
      log("🚨 Web Notification Initialization Error: $e");
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      if (notification == null) return;

      log('🔔 Notification Title: ${notification.title}');
      log('📝 Notification Body: ${notification.body}');

      if (kIsWeb) {
        _showWebSnackbar(
          title: notification.title ?? 'New Notification',
          body: notification.body ?? 'You have a new message',
        );
      } else {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        );

        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        final NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? "New Notification",
          notification.body ?? "You have a new message",
          platformDetails,
          payload: message.data.toString(),
        );
      }
    } catch (e) {
      log("🚨 Error Showing Notification: $e");
    }
  }

  static void _handleNotification(RemoteMessage message) {
    log("📂 Notification Data: ${message.data}");
    if (navigatorKey.currentState != null) {
      final data = message.data;
      if (data['type'] == 'patient_info') {
        navigatorKey.currentState!.pushNamed('/patientInfo');
      } else {
        navigatorKey.currentState!.pushNamed('/login');
      }
    }
  }

  static void _showWebSnackbar({required String title, required String body}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          Future.delayed(Duration(seconds: 5), () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.redAccent),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
