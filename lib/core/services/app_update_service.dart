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

    final latestVersion = data['latestVersion']?.toString().trim() ?? '';
    final minimumVersion = data['minimumVersion']?.toString().trim() ?? '';
    final currentVsLatest = _compareVersions(currentVersion, latestVersion);
    final currentVsMinimum = _compareVersions(currentVersion, minimumVersion);

    // No update prompt when current version is latest or newer.
    if (latestVersion.isNotEmpty && currentVsLatest >= 0) {
      return null;
    }

    // When latestVersion is missing, avoid false prompts.
    if (latestVersion.isEmpty) return null;

    final hasUpdate = currentVsLatest < 0;
    if (!hasUpdate) return null;

    final storeUrl =
        data['iosStoreUrl']?.toString() ??
        'https://apps.apple.com/app/id6797599845';

    // Force update if backend explicitly flags it or app is below minimum version.
    final forceUpdate =
        data['forceUpdate'] == true ||
        (minimumVersion.isNotEmpty && currentVsMinimum < 0);

    return AppUpdateResult(forceUpdate: forceUpdate, storeUrl: storeUrl);
  }

  int _compareVersions(String current, String target) {
    if (current.trim().isEmpty || target.trim().isEmpty) return 0;

    List<int> toParts(String value) {
      final cleaned = value.trim().split('+').first;
      return cleaned
          .split('.')
          .map(
            (part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          )
          .toList();
    }

    final a = toParts(current);
    final b = toParts(target);
    final length = a.length > b.length ? a.length : b.length;

    for (int i = 0; i < length; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av > bv) return 1;
      if (av < bv) return -1;
    }
    return 0;
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
