import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../env.dart';

class AppUpdateResult {
  const AppUpdateResult({required this.forceUpdate, required this.storeUrl});

  final bool forceUpdate;
  final String storeUrl;
}

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  String get _updateEndpoint => '${Env.baseUrl}/api/public/app/version-check';

  Future<AppUpdateResult?> checkForUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    final updateInfo = await _fetchRemoteUpdateInfo(
      currentVersion,
      buildNumber,
    );
    if (updateInfo == null) return null;

    final data = updateInfo['data'];
    if (data is! Map<String, dynamic>) return null;

    final message = data['message']?.toString() ?? '';
    final hasUpdate = message.toLowerCase().contains('latest version') == false;

    if (!hasUpdate) return null;

    final storeUrl =
        data['iosStoreUrl']?.toString() ??
        'https://apps.apple.com/app/id6797599845';
    final forceUpdate = data['forceUpdate'] == true;

    return AppUpdateResult(forceUpdate: forceUpdate, storeUrl: storeUrl);
  }

  Future<Map<String, dynamic>?> _fetchRemoteUpdateInfo(
    String currentVersion,
    String buildNumber,
  ) async {
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 8)));
      final response = await dio.post(
        _updateEndpoint,
        data: {
          'platform': 'ios',
          'appVersion': currentVersion,
          'buildNumber': buildNumber,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {
      // Ignore network issues and fall back silently.
    }
    return null;
  }

  Future<void> openStore(String storeUrl) async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
