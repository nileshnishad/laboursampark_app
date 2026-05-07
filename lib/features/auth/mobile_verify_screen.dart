import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../core/auth_service.dart';
import '../../services/api_service.dart';
import '../dashboard/user_dashboard_screen.dart';

class MobileVerifyScreen extends StatefulWidget {
  final String phone; // e.g. "+919876543210"
  final String displayPhone; // e.g. "98765 43210"
  final String? userId;

  const MobileVerifyScreen({
    super.key,
    required this.phone,
    required this.displayPhone,
    this.userId,
  });

  @override
  State<MobileVerifyScreen> createState() => _MobileVerifyScreenState();
}

class _MobileVerifyScreenState extends State<MobileVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _currentPhone;
  bool _editingPhone = false;
  final TextEditingController _phoneEditController = TextEditingController();

  bool _otpSent = false;
  bool _sending = false;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentPhone = widget.phone;
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _phoneEditController.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _startEditPhone() {
    final digits = _currentPhone.replaceAll('+91', '').replaceAll(' ', '');
    _phoneEditController.text = digits;
    setState(() { _editingPhone = true; _error = null; });
  }

  Future<void> _sendOtp() async {
    // If editing, use the edited number directly
    if (_editingPhone) {
      final raw = _phoneEditController.text.trim();
      if (raw.length < 10) {
        setState(() => _error = 'Enter a valid 10-digit mobile number');
        return;
      }
      _currentPhone = raw.startsWith('+') ? raw : '+91$raw';
      _editingPhone = false;
      for (final c in _controllers) c.clear();
    }
    setState(() { _sending = true; _error = null; });
    final res = await ApiService.sendOtp(_currentPhone, userId: widget.userId);
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() { _otpSent = true; _sending = false; });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNodes[0].requestFocus();
      });
    } else {
      setState(() {
        _sending = false;
        _error = res['message']?.toString() ?? 'Failed to send OTP';
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      setState(() => _error = 'Please enter the 6-digit OTP');
      return;
    }
    setState(() { _verifying = true; _error = null; });
    final res = await ApiService.verifyOtp(_currentPhone, _otp);
    if (!mounted) return;
    if (res['success'] == true) {
      await AuthService.setOtpVerified(true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number verified successfully!'),
          backgroundColor: Color(0xFF059669),
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
      );
    } else {
      setState(() {
        _verifying = false;
        _error = res['message']?.toString() ?? 'Invalid OTP. Please try again.';
        // Clear OTP fields on failure
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      });
    }
  }

  void _onOtpDigit(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isNotEmpty) setState(() {});
    if (_otp.length == 6) _verifyOtp();
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        setState(() {});
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: const Color(0xFF111827)),
        title: const Text(
          'Verify Mobile Number',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.phone_android, size: 52, color: Color(0xFF2563EB)),
              const SizedBox(height: 20),
              const Text(
                'Mobile Verification Required',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              Text(
                'Your mobile number needs to be verified before you can continue.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Phone display / edit
              if (_editingPhone) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneEditController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: '',
                          prefixText: '+91 ',
                          labelText: 'Mobile Number',
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                          ),
                        ),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(() { _editingPhone = false; _error = null; }),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Color(0xFF2563EB), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentPhone,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                      ),
                      if (!_otpSent)
                        TextButton.icon(
                          onPressed: _startEditPhone,
                          icon: const Icon(Icons.edit, size: 16, color: Color(0xFF2563EB)),
                          label: const Text('Edit',
                              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),

              if (!_otpSent) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _sending
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ] else ...[
                const Text(
                  'Enter the 6-digit OTP sent to your number',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                ),
                const SizedBox(height: 16),

                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final isFilled = _controllers[i].text.isNotEmpty;
                    return SizedBox(
                      width: 46,
                      height: 56,
                      child: Focus(
                        onKeyEvent: (node, event) => _handleKeyEvent(i, event),
                        child: TextFormField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          enableInteractiveSelection: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            filled: true,
                            fillColor: isFilled
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isFilled
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Color(0xFF2563EB), width: 2),
                            ),
                          ),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B)),
                          onChanged: (v) => _onOtpDigit(i, v),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _verifying
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: _sending ? null : _sendOtp,
                    child: Text(
                      _sending ? 'Sending...' : 'Resend OTP',
                      style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
