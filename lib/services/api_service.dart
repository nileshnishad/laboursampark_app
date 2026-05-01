import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/env.dart';

class ApiService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '${Env.baseUrl}/auth/login',
      data: jsonEncode({
        'email': email,
        'password': password,
      }),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return response.data as Map<String, dynamic>;
  }
}
