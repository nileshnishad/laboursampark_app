import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import '../../core/services/permission_service.dart';
import '../auth/login_screen.dart';
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
      await PermissionService.requestStartupPermissionsIfNeeded(context);
      if (!mounted) return;
      bool loggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;
      if (loggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        );
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
              'Connect Labourers & Contractors',
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
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'LS',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2563EB),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

