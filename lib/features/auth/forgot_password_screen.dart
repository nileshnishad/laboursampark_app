import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/api_service.dart';
import '../../common/widgets/app_primary_button.dart';
import '../../common/widgets/app_text_field.dart';
import '../../utils/toast_utils.dart';

/// Custom formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

enum ForgotPasswordStep {
  enterEmail,
  enterOtp,
  resetPassword,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordStep _currentStep = ForgotPasswordStep.enterEmail;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _autoValidate = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _userId;
  String? _verifiedEmail;
  
  // Timer for resend OTP cooldown
  Timer? _resendTimer;
  int _resendCooldownSeconds = 0;
  static const int _resendCooldownDuration = 600; // 10 minutes in seconds

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listen to password changes to update validation UI
    _newPasswordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldownSeconds = _resendCooldownDuration;
    });
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldownSeconds > 0) {
        setState(() {
          _resendCooldownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatCooldownTime() {
    final minutes = (_resendCooldownSeconds / 60).floor();
    final seconds = _resendCooldownSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Password validation helper
  bool _hasMinLength(String password) => password.length >= 8;
  bool _hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  bool _hasNumber(String password) => password.contains(RegExp(r'[0-9]'));
  
  bool _isPasswordValid(String password) {
    return _hasMinLength(password) &&
           _hasUppercase(password) &&
           _hasLowercase(password) &&
           _hasNumber(password);
  }
  
  String? _getPasswordError(String password) {
    if (password.isEmpty) return null;
    
    final errors = <String>[];
    if (!_hasMinLength(password)) errors.add('8 characters');
    if (!_hasUppercase(password)) errors.add('uppercase letter');
    if (!_hasLowercase(password)) errors.add('lowercase letter');
    if (!_hasNumber(password)) errors.add('number');
    
    if (errors.isEmpty) return null;
    return 'Must contain: ${errors.join(', ')}';
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    
    if (email.isEmpty) {
      ToastUtils.showError('Please enter your email');
      return;
    }
    
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ToastUtils.showError('Please enter a valid email');
      return;
    }
    
    // Check if cooldown is still active
    if (_resendCooldownSeconds > 0) {
      ToastUtils.showError('Please wait ${_formatCooldownTime()} before requesting another OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.sendPasswordResetOtp(email);
      
      if (res['success'] == true) {
        ToastUtils.showSuccess(res['message'] ?? 'OTP sent to your email');
        _startResendCooldown(); // Start 10-minute cooldown
        setState(() {
          _currentStep = ForgotPasswordStep.enterOtp;
          _verifiedEmail = email;
        });
      } else {
        ToastUtils.showError(res['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      ToastUtils.showError('Failed to send OTP: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim().toUpperCase();
    
    if (otp.isEmpty) {
      ToastUtils.showError('Please enter the OTP');
      return;
    }
    
    if (otp.length < 6) {
      ToastUtils.showError('Please enter a valid 6-character OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.verifyPasswordResetOtp(_verifiedEmail!, otp);
      
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        _userId = data['userId'] as String?;
        
        if (_userId == null) {
          ToastUtils.showError('Invalid response from server');
          return;
        }
        
        ToastUtils.showSuccess(res['message'] ?? 'OTP verified successfully');
        _resendTimer?.cancel(); // Cancel timer on successful verification
        setState(() {
          _currentStep = ForgotPasswordStep.resetPassword;
          _resendCooldownSeconds = 0;
        });
      } else {
        ToastUtils.showError(res['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      ToastUtils.showError('Failed to verify OTP: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    setState(() => _autoValidate = true);
    
    if (newPassword.isEmpty) {
      ToastUtils.showError('Please enter new password');
      return;
    }
    
    if (!_isPasswordValid(newPassword)) {
      ToastUtils.showError('Password does not meet requirements');
      return;
    }
    
    if (confirmPassword.isEmpty) {
      ToastUtils.showError('Please confirm your password');
      return;
    }
    
    if (newPassword != confirmPassword) {
      ToastUtils.showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiService.resetPassword(_userId!, newPassword, confirmPassword);
      
      if (res['success'] == true) {
        ToastUtils.showSuccess(res['message'] ?? 'Password reset successfully');
        
        // Navigate back to login screen
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ToastUtils.showError(res['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      ToastUtils.showError('Failed to reset password: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green[700] : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? Colors.green[700] : Colors.grey[700],
                fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.email_outlined,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your registered email address and we\'ll send you an OTP to reset your password.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Note: You can resend OTP after 10 minutes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue[900],
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AppTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _sendOtp(),
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: _resendCooldownSeconds > 0
              ? 'Wait ${_formatCooldownTime()}'
              : 'Send OTP',
          icon: Icons.send,
          isLoading: _isLoading,
          onPressed: _resendCooldownSeconds > 0 ? null : _sendOtp,
        ),
        if (_resendCooldownSeconds > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Please wait before requesting another OTP',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.lock_outline,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        Text(
          'Enter OTP',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a 6-character OTP to\n$_verifiedEmail',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),
        AppTextField(
          controller: _otpController,
          label: 'OTP Code',
          hint: 'Enter 6-character OTP (e.g., K9M3P7)',
          prefixIcon: Icons.pin,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _verifyOtp(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(6),
            UpperCaseTextFormatter(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive OTP? ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_resendCooldownSeconds > 0)
              Text(
                'Resend in ${_formatCooldownTime()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              )
            else
              TextButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: const Text(
                  'Resend',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        if (_resendCooldownSeconds > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'You can request a new OTP after the timer expires',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
            ),
          ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Verify OTP',
          icon: Icons.check_circle,
          isLoading: _isLoading,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _resendCooldownSeconds > 0
              ? null
              : () {
                  setState(() {
                    _currentStep = ForgotPasswordStep.enterEmail;
                    _otpController.clear();
                  });
                },
          child: Text(
            _resendCooldownSeconds > 0
                ? 'Cannot change email during cooldown'
                : 'Change Email',
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.lock_reset,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create a strong password',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Requirements:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement(
                'At least 8 characters',
                _hasMinLength(_newPasswordController.text),
              ),
              _buildPasswordRequirement(
                'One uppercase letter (A-Z)',
                _hasUppercase(_newPasswordController.text),
              ),
              _buildPasswordRequirement(
                'One lowercase letter (a-z)',
                _hasLowercase(_newPasswordController.text),
              ),
              _buildPasswordRequirement(
                'One number (0-9)',
                _hasNumber(_newPasswordController.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AppTextField(
          controller: _newPasswordController,
          label: 'New Password',
          hint: 'Enter new password',
          prefixIcon: Icons.lock,
          obscureText: _obscureNewPassword,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
            icon: Icon(
              _obscureNewPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          errorText: _autoValidate && _newPasswordController.text.isNotEmpty
              ? _getPasswordError(_newPasswordController.text.trim())
              : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter new password',
          prefixIcon: Icons.lock,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _resetPassword(),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          errorText: _autoValidate &&
                  _confirmPasswordController.text.isNotEmpty &&
                  _confirmPasswordController.text.trim() !=
                      _newPasswordController.text.trim()
              ? 'Passwords do not match'
              : null,
        ),
        const SizedBox(height: 24),
        AppPrimaryButton(
          label: 'Reset Password',
          icon: Icons.check,
          isLoading: _isLoading,
          onPressed: _isPasswordValid(_newPasswordController.text.trim()) &&
                  _newPasswordController.text.trim() ==
                      _confirmPasswordController.text.trim()
              ? _resetPassword
              : null,
        ),
        if (!_isPasswordValid(_newPasswordController.text.trim()) &&
            _newPasswordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Please meet all password requirements',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (_currentStep == ForgotPasswordStep.enterEmail)
                _buildEmailStep()
              else if (_currentStep == ForgotPasswordStep.enterOtp)
                _buildOtpStep()
              else
                _buildResetPasswordStep(),
            ],
          ),
        ),
      ),
    );
  }
}
