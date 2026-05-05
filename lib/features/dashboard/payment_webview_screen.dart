import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    show AndroidWebViewController;
import 'package:get/get.dart';
import '../../core/user_controller.dart';
import '../../core/auth_service.dart';
import '../../services/api_service.dart';

/// Result returned when the WebView closes.
enum PaymentResult { success, failure, cancelled }

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String title;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.title = 'Complete Payment',
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _loading = true;
  int _loadingProgress = 0;
  bool _upiLaunched = false;
  bool _paymentResolved = false;
  bool _verifyingUpi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 12; Mobile) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // Handle UPI intent URLs — launch via Android intent system
            // so GPay / PhonePe / Paytm etc. can open
            if (url.startsWith('intent://') ||
                url.startsWith('upi://') ||
                url.startsWith('tez://') ||
                url.startsWith('phonepe://') ||
                url.startsWith('paytmmp://')) {
              _upiLaunched = true;
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
                  .catchError((_) {
                return false;
              });
              return NavigationDecision.prevent;
            }

            // Detect PayU success redirect
            if (url.contains('laboursampark.com/payment/success') ||
                url.contains('/payment/success')) {
              if (!_paymentResolved) {
                _paymentResolved = true;
                Navigator.of(context).pop(PaymentResult.success);
              }
              return NavigationDecision.prevent;
            }

            // Detect PayU failure redirect
            if (url.contains('laboursampark.com/payment/failure') ||
                url.contains('/payment/failure')) {
              if (!_paymentResolved) {
                _paymentResolved = true;
                Navigator.of(context).pop(PaymentResult.failure);
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // Non-fatal, let user see the page
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    // Android: allow mixed content so PayU payment page loads fully
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  /// Called when user returns from UPI app back to this app.
  /// Don't reload — PayU's own JS polling may still work.
  /// Instead, poll our backend directly to check payment status.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _upiLaunched && !_paymentResolved) {
      _upiLaunched = false;
      _pollPaymentStatus();
    }
  }

  Future<void> _pollPaymentStatus() async {
    if (!mounted) return;
    setState(() => _verifyingUpi = true);

    final userController = Get.find<UserController>();
    final token =
        userController.token.value ?? await AuthService.getAuthToken();
    if (token == null) {
      if (mounted) setState(() => _verifyingUpi = false);
      return;
    }

    // Poll up to 10 times with 4s gap (40s total — PayU webhook usually fires within 10-20s)
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted || _paymentResolved) break;
      final res = await ApiService.fetchProfile(token);
      if (res['success'] == true && res['data'] is Map<String, dynamic>) {
        final profile = res['data'] as Map<String, dynamic>;
        final active = (profile['display'] as bool?) ?? false;
        if (active) {
          _paymentResolved = true;
          if (mounted) Navigator.of(context).pop(PaymentResult.success);
          return;
        }
      }
    }

    // Not confirmed after 40s — show manual button
    if (mounted) setState(() => _verifyingUpi = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel payment',
          onPressed: () => Navigator.of(context).pop(PaymentResult.cancelled),
        ),
        bottom: _loading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: const Color(0xFF1976D2),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            // Overlay shown while polling backend after UPI app returns
            if (_verifyingUpi)
              Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 20),
                      const Text(
                        'Verifying payment...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please wait, do not close the app',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
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
