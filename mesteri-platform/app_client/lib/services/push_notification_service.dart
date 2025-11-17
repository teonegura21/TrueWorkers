import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Dio _dio = Dio();
  
  String? _fcmToken;
  Function(RemoteMessage)? onNotificationTap;

  Future<void> initialize({required String apiBaseUrl, Function(RemoteMessage)? onTap}) async {
    onNotificationTap = onTap;
    
    // Request permissions (especially for iOS)
    await _requestPermissions();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Get FCM token and register with backend
    await _getFCMToken(apiBaseUrl);
    
    // Setup message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Handle initial message if app was opened from notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
    
    // Token refresh listener
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _registerTokenWithBackend(token, apiBaseUrl);
    });
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permissions');
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mesteri_notifications',
      'Mesteri Notifications',
      description: 'Notification channel for Mesteri Platform',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _getFCMToken(String apiBaseUrl) async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        print('FCM Token: $_fcmToken');
        await _registerTokenWithBackend(_fcmToken!, apiBaseUrl);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _registerTokenWithBackend(String token, String apiBaseUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated, skipping token registration');
        return;
      }

      final idToken = await user.getIdToken();
      final platform = Platform.isIOS ? 'IOS' : Platform.isAndroid ? 'ANDROID' : 'WEB';

      await _dio.post(
        '$apiBaseUrl/notifications/register-token',
        data: {
          'token': token,
          'platform': platform,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      print('Device token registered successfully');
    } catch (e) {
      print('Error registering device token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    if (onNotificationTap != null) {
      onNotificationTap!(message);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    print('Notification response: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final message = RemoteMessage(data: data);
        _handleNotificationTap(message);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mesteri_notifications',
      'Mesteri Notifications',
      channelDescription: 'Notification channel for Mesteri Platform',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> removeToken(String apiBaseUrl) async {
    try {
      if (_fcmToken == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();

      await _dio.post(
        '$apiBaseUrl/notifications/remove-token',
        data: {'token': _fcmToken},
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      print('Device token removed successfully');
    } catch (e) {
      print('Error removing device token: $e');
    }
  }

  String? get fcmToken => _fcmToken;
}
