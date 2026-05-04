import 'package:flutter/material.dart';
import 'user_type_selection_screen.dart';
import '../dashboard/user_dashboard_screen.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../common/widgets/app_primary_button.dart';
import '../../common/widgets/app_text_field.dart';
import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../utils/toast_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrMobileController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _autoValidate = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

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

  Future<void> _submitLogin() async {
    if (!_isFormValid) {
      setState(() {
        _autoValidate = true;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    try {
      final res = await ApiService.login(
        _emailOrMobileController.text.trim(),
        _passwordController.text.trim(),
      );

      if (res['success'] == true && res['data'] != null) {
        final user = res['data']['user'] as Map<String, dynamic>;
        final token = res['data']['token'] as String;
        final userController = Get.find<UserController>();
        userController.setUser(user, token);
        ToastUtils.showSuccess(res['message'] ?? 'Login successful');
        await AuthService.setAuthToken(token);
        await AuthService.setUserData(user);
        await AuthService.setLoggedIn(true);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        );
      } else {
        ToastUtils.showError(res['message'] ?? 'Login failed');
      }
    } catch (e) {
      ToastUtils.showError('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // LS Logo branding matching web app
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                   
                    
                    
                    
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to your account',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 40),
              AppTextField(
                controller: _emailOrMobileController,
                label: 'Email or mobile number',
                hint: 'name@example.com or +91xxxxxxxxxx',
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText:
                    _autoValidate &&
                        _emailOrMobileController.text.trim().isEmpty
                    ? 'Please enter email or mobile'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitLogin(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                errorText:
                    _autoValidate && _passwordController.text.trim().isEmpty
                    ? 'Please enter password'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() => _rememberMe = val ?? false);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Remember me', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ToastUtils.showError(
                        'Forgot password feature coming soon',
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: _isSubmitting ? 'Signing in...' : 'Sign In',
                isLoading: _isSubmitting,
                icon: Icons.login_rounded,
                onPressed: _submitLogin,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      'OR',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ToastUtils.showError('Google sign in feature coming soon');
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserTypeSelectionScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: Text(
                        'Create Account',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Need help? Call support: +91 9172272305',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
