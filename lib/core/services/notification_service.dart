import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/mobile_verify_screen.dart';
import '../../features/dashboard/user_dashboard_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../services/api_service.dart';
import '../auth_service.dart';
import '../user_controller.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'laboursampark_channel',
    'Labour Sampark Notifications',
    description: 'General notifications from Labour Sampark',
    importance: Importance.high,
  );

  static String? normalizeRoute(String? rawRoute) {
    final route = rawRoute?.trim().toLowerCase();
    if (route == null || route.isEmpty) return null;
    if (route == 'jobs' || route == 'job') return 'jobs';
    if (route == 'profile' || route == 'settings') return 'profile';
    return route;
  }

  Future<void> initialize() async {
    if (!DefaultFirebaseOptions.hasCurrentPlatformConfig) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationPayload(response.payload);
      },
    );

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await messaging.subscribeToTopic('all_users');
      await messaging.subscribeToTopic('announcements');
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationPayload(message.data['route']?.toString());
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      unawaited(_registerCurrentToken(token));
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationPayload(initialMessage.data['route']?.toString());
      });
    }

    await _registerCurrentToken(await messaging.getToken());
  }

  Future<void> _registerCurrentToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) return;

    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : null;
    final authToken = userController?.token.value;
    if (authToken == null || authToken.isEmpty) return;

    await ApiService.registerFcmToken(token: authToken, fcmToken: token);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;
    final title =
        notification?.title ??
        message.data['title']?.toString() ??
        message.data['notificationTitle']?.toString() ??
        'Labour Sampark';
    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        message.data['notificationBody']?.toString() ??
        'You have a new update';

    if (title.trim().isEmpty && body.trim().isEmpty) return;

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          color: const Color(0xFF2563EB),
          ticker: title,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Labour Sampark',
            htmlFormatContent: false,
            htmlFormatTitle: false,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route']?.toString(),
    );
  }

  void _handleNotificationPayload(String? route) {
    final normalizedRoute = normalizeRoute(route);
    _navigateToRoute(normalizedRoute);
  }

  Future<void> _navigateToRoute(String? route) async {
    final navigator = Get.key.currentState;
    if (navigator == null) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    final otpVerified = await AuthService.isOtpVerified();
    if (!otpVerified) {
      final userData = await AuthService.getUserData();
      final phone =
          (userData?['phone'] ??
                  userData?['mobile'] ??
                  userData?['mobileNumber'] ??
                  '')
              .toString();
      final userId = (userData?['_id'] ?? userData?['id'] ?? '').toString();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MobileVerifyScreen(
            phone: phone.startsWith('+') ? phone : '+91$phone',
            displayPhone: phone,
            userId: userId,
          ),
        ),
        (route) => false,
      );
      return;
    }

    if (route == 'profile') {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
        (route) => false,
      );
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
      (route) => false,
    );
  }
}
