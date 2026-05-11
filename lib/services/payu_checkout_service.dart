import 'package:flutter/material.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';

import '../core/user_controller.dart';
import '../core/auth_service.dart';
import 'api_service.dart';

/// Callbacks called by the widget that launched the native checkout.
typedef PayUSuccessCallback = void Function(dynamic response);
typedef PayUFailureCallback = void Function(dynamic response);
typedef PayUCancelCallback = void Function(Map<String, dynamic>? response);

/// Opens the PayU native CheckoutPro screen.
///
/// Calls `/api/payments/payu/init` to get signed payment params, then
/// hands off to the native SDK.  All three outcome callbacks are required.
class PayUCheckoutService extends PayUCheckoutProProtocol {
  final BuildContext context;
  final double amount;
  final String productInfo;
  final int visibilityDays;
  final UserController userController;
  final PayUSuccessCallback onSuccess;
  final PayUFailureCallback onFailure;
  final PayUCancelCallback onCancel;

  late final PayUCheckoutProFlutter _checkout;
  String? _authToken; // stored after init so generateHash can use it

  PayUCheckoutService({
    required this.context,
    required this.amount,
    required this.productInfo,
    required this.visibilityDays,
    required this.userController,
    required this.onSuccess,
    required this.onFailure,
    required this.onCancel,
  }) {
    _checkout = PayUCheckoutProFlutter(this);
  }

  /// Call this to start the payment flow.
  Future<void> launch() async {
    debugPrint('[PayU] ▶ launch() called — amount=$amount productInfo=$productInfo visibilityDays=$visibilityDays');

    final token =
        userController.token.value ?? await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      debugPrint('[PayU] ✖ No auth token — aborting');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
      }
      return;
    }
    _authToken = token; // store so generateHash can use it
    debugPrint('[PayU] ✔ Token present (${token.length} chars)');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Initialising payment...'),
          ]),
          duration: Duration(seconds: 10),
        ),
      );
    }

    debugPrint('[PayU] ▶ Calling createPaymentInit...');
    final result = await ApiService.createPaymentInit(
      amount: amount,
      productInfo: productInfo,
      token: token,
      visibilityDays: visibilityDays,
    );
    debugPrint('[PayU] ◀ createPaymentInit response: $result');

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    if (result['success'] != true || result['data'] is! Map<String, dynamic>) {
      debugPrint('[PayU] ✖ Init failed — success=${result['success']} data=${result['data']?.runtimeType}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ??
                'Could not initialise payment'),
          ),
        );
      }
      return;
    }

    final data = result['data'] as Map<String, dynamic>;
    // PayU native SDK requires txnid to be alphanumeric only — strip underscores
    final rawTxnid = data['txnid']?.toString() ?? '';
    final cleanTxnid = rawTxnid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    debugPrint('[PayU] ✔ Init data keys: ${data.keys.toList()}');
    debugPrint('[PayU]   key       = ${data['key']}');
    debugPrint('[PayU]   txnid     = $rawTxnid  →  cleanTxnid = $cleanTxnid');
    debugPrint('[PayU]   amount    = ${data['amount']}');
    debugPrint('[PayU]   firstname = ${data['firstname']}');
    debugPrint('[PayU]   email     = ${data['email']}');
    debugPrint('[PayU]   phone     = ${data['phone']}');
    debugPrint('[PayU]   surl      = ${data['surl']}');
    debugPrint('[PayU]   furl      = ${data['furl']}');
    debugPrint('[PayU]   udf1      = ${data['udf1']}');
    debugPrint('[PayU]   hash      = ${(data['hash'] as String?)?.substring(0, 20)}...');
    debugPrint('[PayU]   environment = ${data['environment']}');

    final Map<String, dynamic> paymentParams = {
      PayUPaymentParamKey.key: data['key']?.toString() ?? '',
      PayUPaymentParamKey.transactionId: cleanTxnid,
      PayUPaymentParamKey.amount: data['amount']?.toString() ?? '',
      PayUPaymentParamKey.productInfo: data['productinfo']?.toString() ?? '',
      PayUPaymentParamKey.firstName: data['firstname']?.toString() ?? '',
      PayUPaymentParamKey.email: data['email']?.toString() ?? '',
      PayUPaymentParamKey.phone: data['phone']?.toString() ?? '',
      PayUPaymentParamKey.android_surl: data['surl']?.toString() ?? '',
      PayUPaymentParamKey.android_furl: data['furl']?.toString() ?? '',
      PayUPaymentParamKey.ios_surl: data['surl']?.toString() ?? '',
      PayUPaymentParamKey.ios_furl: data['furl']?.toString() ?? '',
      PayUPaymentParamKey.userCredential:
          '${data['key']}:${data['email'] ?? ''}',
      PayUPaymentParamKey.environment: '0', // 0 = production, 1 = test
      'hash': data['hash']?.toString() ?? '',
    };

    // udf1 carries the internal paymentId for backend reconciliation
    if (data['udf1'] != null) {
      paymentParams[PayUPaymentParamKey.additionalParam] = {
        'udf1': data['udf1'].toString(),
      };
    }

    debugPrint('[PayU] ▶ paymentParams assembled: ${paymentParams.keys.toList()}');

    final checkoutConfig = {
      PayUCheckoutProConfigKeys.primaryColor: '#1976D2',
      PayUCheckoutProConfigKeys.secondaryColor: '#FFFFFF',
      PayUCheckoutProConfigKeys.merchantName: 'LabourSampark',
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.autoApprove: false,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
    };

    debugPrint('[PayU] ▶ Calling openCheckoutScreen...');
    _checkout.openCheckoutScreen(
      payUPaymentParams: paymentParams,
      payUCheckoutProConfig: checkoutConfig,
    );
    debugPrint('[PayU] ✔ openCheckoutScreen called');
  }

  // ─── PayUCheckoutProProtocol callbacks ───────────────────────────────────

  @override
  void generateHash(Map response) {
    debugPrint('[PayU] ▶ generateHash called — hashName=${response[PayUHashConstantsKeys.hashName]}');
    final hashName   = response[PayUHashConstantsKeys.hashName]?.toString() ?? '';
    final hashString = response[PayUHashConstantsKeys.hashString]?.toString() ?? '';
    debugPrint('[PayU]   hashString to sign: $hashString');

    // Call backend to compute sha512(hashString + salt) — salt never leaves the server
    ApiService.computePayUHash(
      hashString: hashString,
      token: _authToken ?? '',
    ).then((result) {
      final hash = result['hash']?.toString() ?? '';
      debugPrint('[PayU]   computed hash (${hash.length} chars): ${hash.isEmpty ? "<empty — backend error>" : "${hash.substring(0, hash.length > 20 ? 20 : hash.length)}..."}');
      _checkout.hashGenerated(hash: {
        PayUHashConstantsKeys.hashName: hashName,
        PayUHashConstantsKeys.hashString: hash,
      });
    }).catchError((e) {
      debugPrint('[PayU] ✖ computePayUHash error: $e — returning empty hash');
      _checkout.hashGenerated(hash: {
        PayUHashConstantsKeys.hashName: hashName,
        PayUHashConstantsKeys.hashString: '',
      });
    });
  }

  @override
  void onPaymentSuccess(dynamic response) {
    debugPrint('[PayU] ✅ onPaymentSuccess: $response');
    onSuccess(response);
  }

  @override
  void onPaymentFailure(dynamic response) {
    debugPrint('[PayU] ❌ onPaymentFailure: $response');
    onFailure(response);
  }

  @override
  void onPaymentCancel(Map? response) {
    debugPrint('[PayU] ⚠️ onPaymentCancel: $response');
    onCancel(response?.cast<String, dynamic>());
  }

  @override
  void onError(Map? response) {
    debugPrint('[PayU] 🔴 onError: $response');
    // Log each key individually for easier reading
    response?.forEach((k, v) => debugPrint('[PayU]   onError[$k] = $v'));
    onFailure(response);
  }
}
