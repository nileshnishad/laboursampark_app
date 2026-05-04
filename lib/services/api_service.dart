import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/app_interceptor.dart';
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
  )..interceptors.add(AppInterceptor());

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

  static Future<Map<String, dynamic>> fetchContractors() async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {
        'success': false,
        'message': ErrorMessages.noInternet,
      };
    }

    try {
      final response = await _dio.get('${Env.baseUrl}/api/users/contractors');
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

  static Future<Map<String, dynamic>> fetchLabours() async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {
        'success': false,
        'message': ErrorMessages.noInternet,
      };
    }

    try {
      final response = await _dio.get('${Env.baseUrl}/api/users/labours');
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

  static Future<Map<String, dynamic>> fetchProfile(String token) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {
        'success': false,
        'message': ErrorMessages.noInternet,
      };
    }

    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/users/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
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

  static Future<Map<String, dynamic>> fetchSubscriptionPlan(
      String userType, String token) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {
        'success': false,
        'message': ErrorMessages.noInternet,
      };
    }

    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/subscription/plan?userType=$userType',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
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

  static Future<Map<String, dynamic>> fetchJobHistory(
      String token, {int page = 1, int limit = 20}) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }

    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/job-history/smart/dashboard?page=$page&limit=$limit',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': AppError.fromDioException(e).userMessage,
      };
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// Get a presigned S3 upload URL. Returns { uploadUrl, fileUrl }.
  static Future<Map<String, dynamic>> getPresignedUploadUrl({
    required String token,
    required String filename,
    required String fileType,
    required String userType,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.post(
        '${Env.baseUrl}/api/upload/presigned-url',
        data: jsonEncode({'filename': filename, 'fileType': fileType, 'userType': userType}),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['uploadUrl'] != null) {
        return {'success': true, 'uploadUrl': data['uploadUrl'], 'fileUrl': data['fileUrl']};
      }
      return {'success': false, 'message': 'Failed to get upload URL'};
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// Upload raw bytes directly to S3 via presigned PUT URL.
  static Future<bool> uploadFileToS3({
    required String presignedUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final response = await _dio.put(
        presignedUrl,
        data: Stream.fromIterable(bytes.map((b) => [b])),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
          followRedirects: false,
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      return response.statusCode != null && response.statusCode! < 400;
    } catch (_) {
      return false;
    }
  }

  /// Create a job posting.
  static Future<Map<String, dynamic>> createJob({
    required String token,
    required Map<String, dynamic> jobData,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.post(
        '${Env.baseUrl}/api/jobs/create-job',
        data: jsonEncode(jobData),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// PUT /api/jobs/:jobId — update an existing job.
  static Future<Map<String, dynamic>> updateJob({
    required String token,
    required String jobId,
    required Map<String, dynamic> jobData,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final url = '${Env.baseUrl}/api/jobs/$jobId';
      debugPrint('══════════════════════════════════════');
      debugPrint('[updateJob] PUT $url');
      debugPrint('[updateJob] Payload: ${jsonEncode(jobData)}');
      debugPrint('══════════════════════════════════════');
      final response = await _dio.put(
        url,
        data: jsonEncode(jobData),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      debugPrint('[updateJob] Response status: ${response.statusCode}');
      debugPrint('[updateJob] Response data: ${jsonEncode(response.data)}');
      debugPrint('══════════════════════════════════════');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('[updateJob] DioException: ${e.response?.statusCode} ${e.response?.data}');
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (e) {
      debugPrint('[updateJob] Unknown error: $e');
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// POST /api/jobs/:jobId/toggle-activation — toggle job visibility (active/inactive).
  static Future<Map<String, dynamic>> toggleJobActivation({
    required String token,
    required String jobId,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.post(
        '${Env.baseUrl}/api/jobs/$jobId/toggle-activation',
        data: jsonEncode({}),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final body = e.response?.data;
      // Return full body so caller can access 'message', 'activeJobs', etc.
      if (body is Map<String, dynamic>) return body;
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// GET /api/jobs/my-jobs — fetch jobs posted by the authenticated contractor/sub-contractor.
  static Future<Map<String, dynamic>> fetchMyJobs(
    String token, {
    int page = 1,
    int limit = 20,
    String? status, // 'open' | 'closed' | null = all
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      final response = await _dio.get(
        '${Env.baseUrl}/api/jobs/my-jobs',
        queryParameters: queryParams,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// GET /api/jobs/getallappliedjobs — pending applications for the current user.
  static Future<Map<String, dynamic>> fetchAllAppliedJobs(
    String token, {
    int page = 1,
    int limit = 100,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/jobs/getallappliedjobs',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// GET /api/jobs/getallacceptedjobs — accepted applications for the current user.
  static Future<Map<String, dynamic>> fetchAllAcceptedJobs(
    String token, {
    int page = 1,
    int limit = 100,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/jobs/getallacceptedjobs',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// GET /api/jobs/getallcompletedjobs — completed jobs for the current user.
  static Future<Map<String, dynamic>> fetchAllCompletedJobs(
    String token, {
    int page = 1,
    int limit = 100,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/jobs/getallcompletedjobs',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// GET /api/jobs/getalljobs — all available jobs for labour / sub_contractor.
  static Future<Map<String, dynamic>> fetchAllJobs(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/jobs/getalljobs',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// Save FCM token to backend after login or on app start.
  static Future<void> registerFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    try {
      await _dio.post(
        '${Env.baseUrl}/api/users/config-check',
        data: jsonEncode({'fcmToken': fcmToken}),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      debugPrint('✅ FCM token registered to backend');
    } catch (e) {
      // Non-critical — don't block user flow
      debugPrint('⚠️ FCM token registration failed: $e');
    }
  }

  /// GET /api/jobs/getApplication?jobId=xxx — fetch all applications for a job.
  static Future<Map<String, dynamic>> fetchJobApplications({
    required String token,
    required String jobId,
    int page = 1,
    int limit = 20,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.get(
        '${Env.baseUrl}/api/jobs/getApplication',
        queryParameters: {'jobId': jobId, 'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// POST /api/job-enquiries/:enquiryId/connect — accept a pending application.
  static Future<Map<String, dynamic>> connectEnquiry({
    required String token,
    required String enquiryId,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.post(
        '${Env.baseUrl}/api/job-enquiries/$enquiryId/connect',
        data: '{}',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  /// POST /api/job-enquiries/:enquiryId/complete — mark accepted application as completed with review.
  static Future<Map<String, dynamic>> completeEnquiry({
    required String token,
    required String enquiryId,
    required double rating,
    required String feedback,
  }) async {
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      return {'success': false, 'message': ErrorMessages.noInternet};
    }
    try {
      final response = await _dio.post(
        '${Env.baseUrl}/api/job-enquiries/$enquiryId/complete',
        data: jsonEncode({'rating': rating, 'feedback': feedback}),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      return {'success': false, 'message': AppError.fromDioException(e).userMessage};
    } catch (_) {
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }
}

