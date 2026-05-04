import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/app_state.dart';
import 'core/user_controller.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
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

    // Print FCM token — if token prints, Firebase is working ✅
    final token = await messaging.getToken();
    debugPrint('✅ FCM TOKEN: $token');

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                title: 'Labour Sampark',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: appState.themeMode,
                home: const SplashScreen(),
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  // Add localization delegates here
                ],
                supportedLocales: const [
                  Locale('en', ''),
                  // Add more locales if needed
                ],
              );
            },
          );
        },
      ),
    );
  }
}

      