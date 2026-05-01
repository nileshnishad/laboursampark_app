
import 'package:flutter/material.dart';
import 'user_type_selection_screen.dart';
import '../dashboard/user_dashboard_screen.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../utils/toast_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrMobileController = TextEditingController(text: 'user5@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '123456');
  bool _rememberMe = false;
  bool _autoValidate = false;

  bool get _isFormValid =>
      _emailOrMobileController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailOrMobileController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'EMAIL OR MOBILE *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailOrMobileController,
                    decoration: InputDecoration(
                      hintText: 'your.email@example.com or +91 XXXXX XXXXX',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      errorText: _autoValidate && _emailOrMobileController.text.trim().isEmpty
                          ? 'Please enter email or mobile'
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      errorText: _autoValidate && _passwordController.text.trim().isEmpty
                          ? 'Please enter password'
                          : null,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) {
                          setState(() => _rememberMe = val ?? false);
                        },
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 14)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: Forgot password logic
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isFormValid
                          ? () async {
                              FocusScope.of(context).unfocus();
                              try {
                                final res = await ApiService.login(
                                  _emailOrMobileController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                if (res['success'] == true && res['data'] != null) {
                                  final user = res['data']['user'] as Map<String, dynamic>;
                                  final token = res['data']['token'] as String;
                                  final userController = Get.put(UserController());
                                  userController.setUser(user, token);
                                  ToastUtils.showSuccess(res['message'] ?? 'Login successful');
                                  await AuthService.setLoggedIn(true);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => UserDashboardScreen(),
                                    ),
                                  );
                                } else {
                                  ToastUtils.showError(res['message'] ?? 'Login failed');
                                }
                              } catch (e) {
                                ToastUtils.showError('Login failed: $e');
                              }
                            }
                          : () {
                              setState(() {
                                _autoValidate = true;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? const Color(0xFF8B7AED)
                            : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        elevation: 0,
                      ),
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Google sign-in logic
                      },
                      icon: const Icon(Icons.login, color: Color(0xFF8B7AED)),
                      label: const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Bottom register bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  border: const Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserTypeSelectionScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register here',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
