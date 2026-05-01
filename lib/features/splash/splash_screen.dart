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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                'assets/logo.jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.person, size: 40, color: Color(0xFF1976D2)),
            const SizedBox(height: 16),
            const Text(
              'Labour Sampark',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

