import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../env.dart';
import '../user_controller.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();
  static const bool _collectStructuredLogData = true;
  static const bool _includeRawErrorDetails = false;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 140,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  Map<String, dynamic>? _cachedContext;
  Map<String, dynamic>? _userContext;
  DateTime? _telegramBackoffUntil;
  DateTime? _lastTelegramFailureLogAt;

  // Call this after login

  void setUserContext({
    required String email,
    String? phone,
    String? userId, // optional if you have it
    String? userRole,
  }) {
    _userContext = {
      'userEmail': email,
      ...?(phone != null ? {'userPhone': phone} : null),
      ...?(userId != null ? {'userId': userId} : null),
      ...?(userRole != null ? {'userRole': userRole} : null),
    };
  }

  // Call this on logout
  void clearUserContext() {
    _userContext = null;
  }

  Future<Map<String, dynamic>> _contextData() async {
    if (_cachedContext != null) {
      return {..._cachedContext!, ...?_userContext};
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final locale = PlatformDispatcher.instance.locale.toString();
    final platform = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();

    final device = <String, dynamic>{
      'platform': platform,
      'locale': locale,
      'isWeb': kIsWeb,
    };

    if (!kIsWeb) {
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      if (deviceInfo is AndroidDeviceInfo) {
        device.addAll({
          'deviceModel': deviceInfo.model,
          'deviceBrand': deviceInfo.brand,
          'deviceManufacturer': deviceInfo.manufacturer,
          'androidVersion': deviceInfo.version.release,
          'androidSdk': deviceInfo.version.sdkInt,
          'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        });
      } else if (deviceInfo is IosDeviceInfo) {
        device.addAll({
          'deviceModel': deviceInfo.utsname.machine,
          'deviceName': deviceInfo.name,
          'deviceSystemName': deviceInfo.systemName,
          'deviceSystemVersion': deviceInfo.systemVersion,
          'isPhysicalDevice': deviceInfo.isPhysicalDevice,
        });
      } else if (deviceInfo is LinuxDeviceInfo) {
        device.addAll({
          'deviceName': deviceInfo.name,
          'deviceVersion': deviceInfo.version,
        });
      } else if (deviceInfo is WebBrowserInfo) {
        device.addAll({
          'browserName': deviceInfo.browserName.name,
        });
      }
    }

    _cachedContext = {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      ...device,
    };
    return {..._cachedContext!, ...?_userContext};
  }

  Map<String, dynamic> _dynamicUserContext() {
    if (!Get.isRegistered<UserController>()) {
      return {};
    }

    final user = Get.find<UserController>().user.value;
    if (user == null) {
      return {};
    }

    final email = (user['email'] ?? user['userEmail'] ?? '').toString().trim();
    final mobile =
        (user['mobile'] ?? user['phone'] ?? user['mobileNumber'] ?? '')
            .toString()
            .trim();
    final userId = (user['_id'] ?? user['id'] ?? '').toString().trim();
    final userCode =
      (user['userCode'] ?? user['code'] ?? '').toString().trim();
    final userRole =
      (user['userType'] ?? user['role'] ?? user['userRole'] ?? '')
        .toString()
        .trim();

    final userContext = <String, dynamic>{};
    if (email.isNotEmpty) {
      userContext['userEmail'] = email;
    }
    if (mobile.isNotEmpty) {
      userContext['userMobile'] = mobile;
    }
    if (userId.isNotEmpty) {
      userContext['userId'] = userId;
    }
    if (userCode.isNotEmpty) {
      userContext['userCode'] = userCode;
    }
    if (userRole.isNotEmpty) {
      userContext['userRole'] = userRole;
    }
    return userContext;
  }

  Future<void> info(
    String event, {
    String? message,
    Map<String, dynamic>? data,
  }) async {
    final enrichedData = _collectStructuredLogData
        ? {
            ...await _contextData(),
            ..._dynamicUserContext(),
            ...?data,
          }
        : null;
    final text = _buildText('INFO', event, message, enrichedData);
    _logger.i(text);
    await _sendToTelegram(text);
  }

  Future<void> warning(
    String event, {
    String? message,
    Map<String, dynamic>? data,
    Object? error,
  }) async {
    final enrichedData = _collectStructuredLogData
        ? {
            ...await _contextData(),
            ..._dynamicUserContext(),
            ...?data,
          }
        : null;
    final text = _buildText(
      'WARNING',
      event,
      message,
      enrichedData,
      error: _includeRawErrorDetails ? error : null,
    );
    _logger.w(text);
    await _sendToTelegram(text);
  }

  Future<void> error(
    String event, {
    String? message,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final enrichedData = _collectStructuredLogData
        ? {
            ...await _contextData(),
            ..._dynamicUserContext(),
            ...?data,
          }
        : null;
    final text = _buildText(
      'ERROR',
      event,
      message,
      enrichedData,
      error: _includeRawErrorDetails ? error : null,
    );
    if (_includeRawErrorDetails && stackTrace != null) {
      _logger.e('$text\n$stackTrace');
    } else {
      _logger.e(text);
    }
    await _sendToTelegram(text);
  }

  Future<void> sendTestLog() async {
    await info('telegram_test', message: 'Telegram logger connectivity test');
  }

  Future<void> logApiRequest(
    String method,
    String path, {
    Map<String, dynamic>? data,
  }) async {
    await info(
      'api_request',
      message: '$method $path',
      data: {'method': method, 'path': path, ...?data},
    );
  }

  Future<void> logApiResponse(
    String method,
    String path,
    int? statusCode, {
    Map<String, dynamic>? data,
  }) async {
    await info(
      'api_response',
      message: '$method $path',
      data: {
        'method': method,
        'path': path,
        'statusCode': statusCode,
        ...?data,
      },
    );
  }

  Future<void> logApiError(
    DioException err, {
    String? message,
    Map<String, dynamic>? data,
  }) async {
    await error(
      'api_error',
      message: message ?? 'Dio request failed',
      data: {
        'method': err.requestOptions.method,
        'path': err.requestOptions.uri.toString(),
        'statusCode': err.response?.statusCode,
        ...?data,
      },
      error: _includeRawErrorDetails ? err : null,
      stackTrace: _includeRawErrorDetails ? err.stackTrace : null,
    );
  }

  String _buildText(
    String level,
    String event,
    String? message,
    Map<String, dynamic>? data, {
    Object? error,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('[$level] $event');
    if (message != null && message.isNotEmpty) {
      buffer.writeln('message: $message');
    }
    if (error != null) {
      buffer.writeln('error: ${error.toString()}');
    }
    if (data != null && data.isNotEmpty) {
      buffer.writeln('data:');
      for (final entry in _sanitize(data).entries) {
        final value = _formatValue(entry.value);
        final valueLines = value.split('\n');
        if (valueLines.length == 1) {
          buffer.writeln('  ${entry.key}: $value');
        } else {
          buffer.writeln('  ${entry.key}:');
          for (final line in valueLines) {
            buffer.writeln('    $line');
          }
        }
      }
    }
    return buffer.toString().trimRight();
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      return value;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    try {
      final sanitized = _safeValue(value);
      return const JsonEncoder.withIndent('  ').convert(sanitized);
    } catch (_) {
      return value.toString();
    }
  }

  Map<String, dynamic> _sanitize(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower.contains('token') ||
          lower.contains('password') ||
          lower.contains('authorization') ||
          lower.contains('secret')) {
        result[key] = '[REDACTED]';
      } else {
        result[key] = _safeValue(entry.value);
      }
    }
    return result;
  }

  dynamic _safeValue(dynamic value) {
    if (value == null) return null;
    if (value is Map || value is List) {
      try {
        return jsonDecode(jsonEncode(value));
      } catch (_) {
        return value.toString();
      }
    }
    if (value is String && value.length > 1200) {
      return '${value.substring(0, 1200)}...[TRUNCATED]';
    }
    return value;
  }

  Future<void> _sendToTelegram(String text) async {
    if (!Env.telegramEnabled) {
      return;
    }

    final now = DateTime.now();
    if (_telegramBackoffUntil != null && now.isBefore(_telegramBackoffUntil!)) {
      return;
    }

    final trimmedText = text.length > 3800
        ? '${text.substring(0, 3800)}...[TRUNCATED]'
        : text;

    try {
      await Dio().post(
        'https://api.telegram.org/bot${Env.telegramBotToken}/sendMessage',
        data: {
          'chat_id': Env.telegramChatId,
          'text': trimmedText,
          'disable_web_page_preview': true,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        _telegramBackoffUntil = DateTime.now().add(const Duration(minutes: 2));
      }
      if (kDebugMode) {
        final now = DateTime.now();
        final shouldLog =
            _lastTelegramFailureLogAt == null ||
            now.difference(_lastTelegramFailureLogAt!) >
                const Duration(seconds: 30);
        if (shouldLog) {
          _lastTelegramFailureLogAt = now;
          debugPrint('Telegram logger failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        final now = DateTime.now();
        final shouldLog =
            _lastTelegramFailureLogAt == null ||
            now.difference(_lastTelegramFailureLogAt!) >
                const Duration(seconds: 30);
        if (shouldLog) {
          _lastTelegramFailureLogAt = now;
          debugPrint('Telegram logger failed: $e');
        }
      }
    }
  }
}
