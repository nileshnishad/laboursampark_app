import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/app_state.dart';
import 'core/auth_service.dart';
import 'core/user_controller.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'features/auth/mobile_verify_screen.dart';
import 'features/splash/splash_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        debugPrint('📬 Foreground notification: ${notification.title} — ${notification.body}');
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
        final phone = (userData?['phone'] ?? userData?['mobile'] ?? userData?['mobileNumber'] ?? '').toString();
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
                home: const SplashScreen(),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [],
                supportedLocales: const [
                  Locale('en', ''),
                ],
              );
            },
          );
        },
      ),
    );
  }
}