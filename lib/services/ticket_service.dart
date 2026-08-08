import 'dart:convert';

import 'package:dio/dio.dart';
import '../core/env.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_messages.dart';
import '../core/services/app_logger.dart';
import '../core/services/network_service.dart';

class TicketService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
    ),
  );

  static Future<Map<String, dynamic>> createTicket({
    required String token,
    required String subject,
    required String message,
    required String category,
    required List<String> attachments,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }

    try {
      final payload = {
        // Keep primary keys and add compatibility keys to match backend variants.
        'subject': subject,
        'title': subject,
        'message': message,
        'description': message,
        'category': category,
        'attachments': attachments,
        'attachmentUrls': attachments,
        'images': attachments,
      };
      await AppLogger.instance.logApiRequest(
        'POST',
        '${Env.baseUrl}/api/tickets',
        data: {
          'subject': subject,
          'category': category,
          'attachmentCount': attachments.length,
          'attachments': attachments,
          'message': message,
        },
      );
      final response = await _dio.post(
        '${Env.baseUrl}/api/tickets',
        data: jsonEncode(payload),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      await AppLogger.instance.logApiResponse(
        'POST',
        '${Env.baseUrl}/api/tickets',
        response.statusCode,
        data: {
          'responseData': response.data,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      await AppLogger.instance.logApiError(
        e,
        message: 'Ticket create request failed',
        data: {
          'requestPayload': {
            'subject': subject,
            'message': message,
            'category': category,
            'attachments': attachments,
          },
          'responseData': e.response?.data,
          'statusMessage': e.response?.statusMessage,
        },
      );
      return {
        'success': false,
        'message': AppError.fromDioException(e).userMessage,
      };
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  static Future<Map<String, dynamic>> fetchMyTickets(String token) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }

    try {
      await AppLogger.instance.logApiRequest(
        'GET',
        '${Env.baseUrl}/api/tickets/my',
      );
      final response = await _dio.get(
        '${Env.baseUrl}/api/tickets/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await AppLogger.instance.logApiResponse(
        'GET',
        '${Env.baseUrl}/api/tickets/my',
        response.statusCode,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      await AppLogger.instance.logApiError(
        e,
        message: 'Fetch my tickets request failed',
      );
      return {
        'success': false,
        'message': AppError.fromDioException(e).userMessage,
      };
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }
}
