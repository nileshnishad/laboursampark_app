import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.level = Level.debug;
  final logger = Logger();
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      await FirebaseCrashlytics.instance.recordFlutterError(details);
      logger.e(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      logger.e('Platform error', error: error, stackTrace: stack);
      return true;
    };
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Subscribe to topics — no backend needed
    // All devices with app installed will get these notifications
    await messaging.subscribeToTopic('all_users');
    await messaging.subscribeToTopic('announcements');
    debugPrint('✅ Subscribed to FCM topics: all_users, announcements');

    // Show notification when app is in FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        debugPrint(
          '📬 Foreground notification: ${notification.title} — ${notification.body}',
        );
      }
    });

    // App opened FROM a notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped: ${message.notification?.title}');
    });
  }
  Get.put(UserController(), permanent: true);
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      if (!loggedIn) return;
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
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        // Only push if not already on MobileVerifyScreen
        final currentRoute = ModalRoute.of(ctx);
        if (currentRoute?.settings.name == '/mobile_verify') return;
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
