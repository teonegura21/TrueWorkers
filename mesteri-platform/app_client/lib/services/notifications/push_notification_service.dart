import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_client/src/core/network/api_client.dart';

// Top-level background message handler - required for Firebase Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main.dart, no need to initialize again
  // Only initialize if not already initialized (for background isolate)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  print('Background message received: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Callback for when notification is tapped
  Function(RemoteMessage)? _onNotificationTap;
  String? _apiBaseUrl;
  
  // Initialize Firebase Messaging
  Future<void> initialize({
    String? apiBaseUrl,
    Function(RemoteMessage)? onTap,
  }) async {
    _apiBaseUrl = apiBaseUrl;
    _onNotificationTap = onTap;
    
    // Request permissions (iOS)
    await _requestPermissions();
    
    // Get FCM token
    String? token = await _messaging.getToken();
    await _registerTokenWithBackend(token);
      
    // Setup message handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Token refresh listener
    _messaging.onTokenRefresh.listen(_registerTokenWithBackend);
    
    // Initialize local notifications
    await _initializeLocalNotifications();
  }
  
  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }
  
  Future<void> _registerTokenWithBackend(String? token) async {
    try {
      if (token == null) {
        debugPrint('No token to register');
        return;
      }
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Use the existing API client to register the device token
      final response = await ApiClient.instance.post(
        '/notifications/register-token',
        data: {
          'token': token,
          'platform': Platform.operatingSystem.toUpperCase(),
        },
      );
      
      if (response.statusCode == 201) {
        debugPrint('Device token registered successfully');
      } else {
        debugPrint('Failed to register device token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error registering token: $e');
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    
    // Display local notification when app is in foreground
    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mesteri_notifications',
          'Mesteri Notifications',
          channelDescription: 'Notifications for Mesteri platform',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
  
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    
    if (_onNotificationTap != null) {
      _onNotificationTap!(message);
    }
  }
  
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle when user taps notification
        if (response.payload != null) {
          final payload = jsonDecode(response.payload!);
          _handleNotificationTap(RemoteMessage(
            data: Map<String, String>.from(payload),
            notification: null,
          ));
        }
      },
    );
    
    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'mesteri_notifications',
      'Mesteri Notifications',
      description: 'Notifications for Mesteri platform',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  // Method to remove token from backend when app is uninstalled or user logs out
  Future<void> removeToken() async {
    try {
      String? token = await _messaging.getToken();
      final response = await ApiClient.instance.post(
        '/notifications/remove-token',
        data: {'token': token},
      );
      
      if (response.statusCode == 200) {
        debugPrint('Device token removed successfully');
      } else {
        debugPrint('Failed to remove device token: ${response.statusCode}');
      }
        } catch (e) {
      debugPrint('Error removing token: $e');
    }
  }
}