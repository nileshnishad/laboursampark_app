import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/widgets/app_primary_button.dart';
import '../../common/widgets/app_text_field.dart';
import '../../services/api_service.dart';
import '../../utils/toast_utils.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;
  bool _linkSent = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final mobile = _mobileController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      ToastUtils.showError('Enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.sendPasswordResetLink(mobile);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _linkSent = true);
      } else {
        ToastUtils.showError(
          result['message']?.toString() ?? 'Could not send reset link',
        );
      }
    } catch (e) {
      if (mounted) ToastUtils.showError('Could not send reset link: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _backToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _linkSent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.lock_reset_rounded, size: 76, color: Colors.blue),
        const SizedBox(height: 20),
        Text(
          'Reset your password',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your registered mobile number and we will send you a password reset link.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        AppTextField(
          controller: _mobileController,
          label: 'Mobile Number',
          hint: 'Enter your 10-digit mobile number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onSubmitted: (_) => _sendResetLink(),
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Send Reset Link',
          icon: Icons.link_rounded,
          isLoading: _isLoading,
          onPressed: _sendResetLink,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 64),
        const Icon(
          Icons.mark_email_read_rounded,
          size: 82,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Text(
          'Reset link sent',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Password reset link has been sent to your mobile number.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        AppPrimaryButton(
          label: 'Back to Login',
          icon: Icons.login_rounded,
          onPressed: _backToLogin,
        ),
      ],
    );
  }
}
