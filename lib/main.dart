import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/app_state.dart';
import 'core/user_controller.dart';
import 'theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
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

      