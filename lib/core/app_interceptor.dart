import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../features/auth/login_screen.dart';
import 'auth_service.dart';
import 'user_controller.dart';

class AppInterceptor extends Interceptor {
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
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Session expired — clear and redirect to login
      AuthService.clearSession().then((_) {
        try {
          Get.find<UserController>().clearUser();
        } catch (_) {}
        Get.offAll(() => const LoginScreen());
      });
    }
    super.onError(err, handler);
  }
}
