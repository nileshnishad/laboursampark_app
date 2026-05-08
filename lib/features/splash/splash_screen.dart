import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../core/auth_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/user_controller.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../auth/mobile_verify_screen.dart';
import '../dashboard/user_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      // Check for Play Store update (Android only, release builds only)
      if (!kIsWeb) {
        try {
          final updateInfo = await InAppUpdate.checkForUpdate();
          if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
            if (updateInfo.immediateUpdateAllowed) {
              await InAppUpdate.performImmediateUpdate();
            } else if (updateInfo.flexibleUpdateAllowed) {
              await InAppUpdate.startFlexibleUpdate();
              await InAppUpdate.completeFlexibleUpdate();
            }
          }
        } catch (_) {
          // Ignore update check errors (e.g. not on Play Store / debug build)
        }
      }
      if (!mounted) return;
      await PermissionService.requestStartupPermissionsIfNeeded(context);
      if (!mounted) return;
      if (!mounted) return;
      bool loggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;
      if (loggedIn) {
        final userController = Get.find<UserController>();
        final restored = await userController.restoreSession();
        if (!mounted) return;
        if (restored) {
          // OTP guard — must be verified before accessing dashboard
          final otpVerified = await AuthService.isOtpVerified();
          if (!otpVerified) {
            final userData = await AuthService.getUserData();
            final phone = (userData?['phone'] ?? userData?['mobile'] ?? userData?['mobileNumber'] ?? '').toString();
            final userId = (userData?['_id'] ?? userData?['id'] ?? '').toString();
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MobileVerifyScreen(
                  phone: phone.startsWith('+') ? phone : '+91$phone',
                  displayPhone: phone,
                  userId: userId,
                ),
              ),
            );
            return;
          }
          // Refresh FCM token on every app open (token can change)
          final fcmToken = await FirebaseMessaging.instance.getToken();
          final authToken = userController.token.value;
          if (fcmToken != null && authToken != null) {
            ApiService.registerFcmToken(token: authToken, fcmToken: fcmToken);
          }
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
          );
        } else {
          // Token/user data corrupted — force re-login
          await AuthService.clearSession();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2563EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LS Logo - matches web app rounded square
            _LSLogo(),
            SizedBox(height: 28),
            Text(
              'LabourSampark',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Connect Labour & Contractors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xCCFFFFFF),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 60),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LSLogo extends StatelessWidget {
  const _LSLogo();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset(
          isDark ? 'assets/images/app_logo_dark.png' : 'assets/images/app_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

