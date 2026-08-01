import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/app_state.dart';
import 'features/settings/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/auth_service.dart';
import 'core/user_controller.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'features/auth/mobile_verify_screen.dart';
import 'features/splash/splash_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'core/services/app_logger.dart';

// ── Local Notifications plugin (singleton) ───────────────────────────────────
final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// Android notification channel — must match AndroidManifest meta-data
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'laboursampark_channel',
  'Labour Sampark Notifications',
  description: 'General notifications from Labour Sampark',
  importance: Importance.high,
);

bool get _isFirebaseConfigured =>
    DefaultFirebaseOptions.hasCurrentPlatformConfig;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!_isFirebaseConfigured) {
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.level = Level.debug;
  final logger = Logger();
  await AppLogger.instance.info('app_started', message: 'App launched');
  await AppLogger.instance.sendTestLog();
  if (!kIsWeb && _isFirebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      await FirebaseCrashlytics.instance.recordFlutterError(details);
      await AppLogger.instance.error(
        'flutter_error',
        message: 'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
      logger.e(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      AppLogger.instance.error(
        'platform_error',
        message: 'Platform error',
        error: error,
        stackTrace: stack,
      );
      logger.e('Platform error', error: error, stackTrace: stack);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── flutter_local_notifications setup ─────────────────────────────────
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification tapped while app in foreground — handled here
        debugPrint('🔔 Local notification tapped: ${response.payload}');
      },
    );

    // Request notification permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Subscribe to topics
    await messaging.subscribeToTopic('all_users');
    await messaging.subscribeToTopic('announcements');
    debugPrint('✅ Subscribed to FCM topics: all_users, announcements');

    // ── Foreground notifications (app open) ───────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null) {
        debugPrint(
          '📬 Foreground FCM: ${notification.title} — ${notification.body}',
        );
        // Show as heads-up local notification so user sees it while in app
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            ),
          ),
          payload: message.data['route']?.toString(),
        );
      }
    });

    // ── Notification tapped (background → foreground) ─────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification opened app: ${message.notification?.title}');
      _handleNotificationRoute(message.data);
    });

    // ── App launched from terminated state via notification tap ───────────
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '🚀 App opened from notification: ${initialMessage.notification?.title}',
      );
      // Delay so the widget tree is ready before navigating
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationRoute(initialMessage.data);
      });
    }
  } else if (!kIsWeb) {
    debugPrint(
      'Firebase is not configured for ${defaultTargetPlatform.name}; skipping iOS-only Firebase setup.',
    );
  }
  Get.put(UserController(), permanent: true);
  runApp(const MyApp());
}

/// Navigate based on the `route` key in the FCM data payload.
/// Backend can send `"data": { "route": "jobs" }` to deep-link into the app.
void _handleNotificationRoute(Map<String, dynamic> data) {
  final route = data['route']?.toString() ?? '';
  debugPrint('📍 Notification route: $route');
  // Add navigation logic here when ready, e.g.:
  // if (route == 'jobs') navigatorKey.currentState?.pushNamed('/jobs');
}

final GlobalKey<NavigatorState> navigatorKey = Get.key;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final loggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;
      if (!loggedIn) return;
      final otpVerified = await AuthService.isOtpVerified();
      if (!mounted) return;
      if (!otpVerified) {
        final userData = await AuthService.getUserData();
        if (!mounted) return;
        final phone =
            (userData?['phone'] ??
                    userData?['mobile'] ??
                    userData?['mobileNumber'] ??
                    '')
                .toString();
        final userId = (userData?['_id'] ?? userData?['id'] ?? '').toString();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/mobile_verify'),
            builder: (_) => MobileVerifyScreen(
              phone: phone.startsWith('+') ? phone : '+91$phone',
              displayPhone: phone,
              userId: userId,
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                title: 'Labour Sampark',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: appState.themeMode,
                locale: appState.locale,
                builder: (context, child) {
                  final media = MediaQuery.of(context);
                  final clampedTextScaler = media.textScaler.clamp(
                    minScaleFactor: 0.9,
                    maxScaleFactor: 1.15,
                  );

                  return MediaQuery(
                    data: media.copyWith(textScaler: clampedTextScaler),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                home: const SplashScreen(),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', ''),
                  Locale('hi', ''),
                  Locale('mr', ''),
                ],
                routes: {'/settings': (_) => const SettingsScreen()},
              );
            },
          );
        },
      ),
    );
  }
}
