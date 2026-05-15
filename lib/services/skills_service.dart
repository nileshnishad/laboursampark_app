import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../common/models/skill_model.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_messages.dart';
import '../core/services/network_service.dart';

class SkillsService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Cache skills data globally
  static List<SkillModel>? _cachedSkills;
  static DateTime? _lastFetchTime;
  static const _cacheValidityDuration = Duration(hours: 24);

  /// Fetch all skills from the API
  /// Returns cached data if available and valid, otherwise fetches fresh data
  static Future<Map<String, dynamic>> getAllSkills({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _cachedSkills != null && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration) {
        // ...existing code...
        return {
          'success': true,
          'skills': _cachedSkills,
          'total': _cachedSkills!.length,
          'fromCache': true,
        };
      }
    }

    // Check internet connectivity
    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      // Return cached data if available even if expired
      if (_cachedSkills != null) {
        // ...existing code...
        return {
          'success': true,
          'skills': _cachedSkills,
          'total': _cachedSkills!.length,
          'fromCache': true,
        };
      }
      return {'success': false, 'message': ErrorMessages.noInternet};
    }

    try {
      // ...existing code...
      final response = await _dio.get(
        'https://laboursampark-backend.vercel.app/api/public/getallskillsname',
        options: Options(
          headers: {
            'accept': '*/*',
            'accept-language': 'en-GB,en;q=0.9,hi-IN;q=0.8,hi;q=0.7,en-US;q=0.6',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true && data['skills'] != null) {
        final skillsList = (data['skills'] as List)
            .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the skills
        _cachedSkills = skillsList;
        _lastFetchTime = DateTime.now();

        // ...existing code...
        
        return {
          'success': true,
          'skills': skillsList,
          'total': skillsList.length,
          'fromCache': false,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch skills',
      };
    } on DioException catch (e) {
      // ...existing code...
      
      // Return cached data if available on error
      if (_cachedSkills != null) {
        // ...existing code...
        return {
          'success': true,
          'skills': _cachedSkills,
          'total': _cachedSkills!.length,
          'fromCache': true,
        };
      }
      
      return {
        'success': false,
        'message': AppError.fromDioException(e).userMessage,
      };
    } catch (e) {
      // ...existing code...
      
      // Return cached data if available on error
      if (_cachedSkills != null) {
        return {
          'success': true,
          'skills': _cachedSkills,
          'total': _cachedSkills!.length,
          'fromCache': true,
        };
      }
      
      return {
        'success': false,
        'message': ErrorMessages.unknown,
      };
    }
  }

  /// Get cached skills if available
  static List<SkillModel>? getCachedSkills() {
    return _cachedSkills;
  }

  /// Clear cached skills
  static void clearCache() {
    _cachedSkills = null;
    _lastFetchTime = null;
    // ...existing code...
  }
}
