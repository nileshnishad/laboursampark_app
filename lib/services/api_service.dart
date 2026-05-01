import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/env.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_messages.dart';
import '../core/services/network_service.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
    ),
  );

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {
        'success': false,
        'message': ErrorMessages.noInternet,
      };
    }

    try {
      final response = await _dio.post(
        '${Env.baseUrl}/auth/login',
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': AppError.fromDioException(e).userMessage,
      };
    } catch (_) {
      return {
        'success': false,
        'message': ErrorMessages.unknown,
      };
    }
  }
}
