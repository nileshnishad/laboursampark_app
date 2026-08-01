import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../features/auth/login_screen.dart';
import 'auth_service.dart';
import 'services/app_logger.dart';
import 'user_controller.dart';

class AppInterceptor extends Interceptor {
  static bool _handlingUnauthorized = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Auto-inject Bearer token if available
    try {
      final userController = Get.find<UserController>();
      final token = userController.token.value;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // UserController not registered yet — skip
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.instance.logApiResponse(
      response.requestOptions.method,
      response.requestOptions.path,
      response.statusCode,
      data: {'statusMessage': response.statusMessage},
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final isUnauthorized = statusCode == 401;
    final isUserLogoutGrace = AuthService.isInUserInitiatedLogoutGrace;

    if (isUnauthorized && isUserLogoutGrace) {
      // User initiated logout can trigger in-flight 401s. Ignore this path.
      super.onError(err, handler);
      return;
    }

    if (isUnauthorized) {
      if (!_handlingUnauthorized) {
        final responseData = err.response?.data;
        final responseMessage = responseData is Map<String, dynamic>
            ? (responseData['message']?.toString() ?? 'Unauthorized')
            : 'Unauthorized';

        AppLogger.instance.warning(
          'api_unauthorized',
          message: 'Session expired or invalid token',
          data: {
            'method': err.requestOptions.method,
            'path': err.requestOptions.uri.toString(),
            'statusCode': statusCode,
            'responseMessage': responseMessage,
          },
        );
      }
    } else {
      AppLogger.instance.logApiError(err, message: 'API request failed');
    }

    if (isUnauthorized && !_handlingUnauthorized) {
      _handlingUnauthorized = true;
      AppLogger.instance.warning(
        'session_expired',
        message: 'User session expired',
      );
      // Session expired — clear and redirect to login
      AuthService.clearSession()
          .then((_) async {
            try {
              Get.find<UserController>().clearUser();
            } catch (_) {}

            final navigator = Get.key.currentState;
            if (navigator != null) {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }

            // Allow future 401 handling after this redirect settles.
            await Future<void>.delayed(const Duration(milliseconds: 800));
            _handlingUnauthorized = false;
          })
          .catchError((_) {
            _handlingUnauthorized = false;
          });
    }
    super.onError(err, handler);
  }
}
