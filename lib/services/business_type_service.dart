import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../common/models/business_type_model.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_messages.dart';
import '../core/services/network_service.dart';

class BusinessTypeService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static List<BusinessTypeModel>? _cachedBusinessTypes;
  static DateTime? _lastFetchTime;
  static const _cacheValidityDuration = Duration(hours: 24);

  static Future<Map<String, dynamic>> getAllBusinessTypes({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedBusinessTypes != null &&
        _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration) {
        return {
          'success': true,
          'businessTypes': _cachedBusinessTypes,
          'total': _cachedBusinessTypes!.length,
          'fromCache': true,
        };
      }
    }

    final hasInternet = await NetworkService.hasInternet();
    if (!hasInternet) {
      if (_cachedBusinessTypes != null) {
        return {
          'success': true,
          'businessTypes': _cachedBusinessTypes,
          'total': _cachedBusinessTypes!.length,
          'fromCache': true,
        };
      }
      return {'success': false, 'message': ErrorMessages.noInternet};
    }

    try {
      final response = await _dio.get(
        'https://laboursampark-backend.vercel.app/api/public/getallbusinessname',
        options: Options(
          headers: {
            'accept': '*/*',
            'accept-language':
                'en-GB,en;q=0.9,hi-IN;q=0.8,hi;q=0.7,en-US;q=0.6',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['businesses'] != null) {
        final businessList = (data['businesses'] as List)
            .map(
              (json) =>
                  BusinessTypeModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        _cachedBusinessTypes = businessList;
        _lastFetchTime = DateTime.now();

        return {
          'success': true,
          'businessTypes': businessList,
          'total': businessList.length,
          'fromCache': false,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch business types',
      };
    } on DioException catch (e) {
      if (_cachedBusinessTypes != null) {
        debugPrint('>>> API error, returning cached business types');
        return {
          'success': true,
          'businessTypes': _cachedBusinessTypes,
          'total': _cachedBusinessTypes!.length,
          'fromCache': true,
        };
      }
      return {
        'success': false,
        'message': AppError.fromDioException(e).userMessage,
      };
    } catch (e) {
      if (_cachedBusinessTypes != null) {
        return {
          'success': true,
          'businessTypes': _cachedBusinessTypes,
          'total': _cachedBusinessTypes!.length,
          'fromCache': true,
        };
      }
      return {'success': false, 'message': ErrorMessages.unknown};
    }
  }

  static List<BusinessTypeModel>? getCachedBusinessTypes() {
    return _cachedBusinessTypes;
  }

  static void clearCache() {
    _cachedBusinessTypes = null;
    _lastFetchTime = null;
    debugPrint('>>> Business types cache cleared');
  }
}
