import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _permissionsPromptedKey = 'permissions_prompted_v1';

  static Future<void> requestStartupPermissionsIfNeeded(BuildContext context) async {
    if (!_isMobilePlatform()) return;

    final prefs = await SharedPreferences.getInstance();
    final hasPrompted = prefs.getBool(_permissionsPromptedKey) ?? false;
    if (hasPrompted) return;

    if (context.mounted) {
      await _showInitialReasonDialog(context);
    }

    final permissions = <Permission>[
      Permission.notification,
      Permission.contacts,
      Permission.camera,
      if (_isAndroidMobilePlatform()) Permission.sms,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isGranted) continue;

      if (context.mounted) {
        await _showSinglePermissionReasonDialog(context, permission);
      }

      final result = await permission.request();
      if (result.isPermanentlyDenied && context.mounted) {
        await _showOpenSettingsDialog(context, permission);
      }
    }

    await prefs.setBool(_permissionsPromptedKey, true);
  }

  static bool _isMobilePlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool _isAndroidMobilePlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static String permissionName(Permission permission) {
    if (permission == Permission.contacts) return 'Contacts';
    if (permission == Permission.camera) return 'Camera';
    if (permission == Permission.notification) return 'Notifications';
    if (permission == Permission.sms) return 'SMS';
    return 'Permission';
  }

  static String permissionReason(Permission permission) {
    if (permission == Permission.contacts) {
      return 'Contacts access helps users connect quickly with known contractors and workers.';
    }
    if (permission == Permission.camera) {
      return 'Camera access is required for profile photo and work-site image uploads.';
    }
    if (permission == Permission.notification) {
      return 'Notification permission helps us send important updates like job alerts, verification status, and account safety messages.';
    }
    if (permission == Permission.sms) {
      return 'SMS access helps with mobile verification and safer account communication.';
    }
    return 'This permission helps improve app experience.';
  }

  static Future<void> _showInitialReasonDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'To provide secure login, updates, and profile features, the app will ask for Notifications, Contacts, Camera, and SMS permissions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showSinglePermissionReasonDialog(
    BuildContext context,
    Permission permission,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${permissionName(permission)} Permission'),
          content: Text(permissionReason(permission)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showOpenSettingsDialog(
    BuildContext context,
    Permission permission,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${permissionName(permission)} Disabled'),
          content: const Text(
            'Permission is permanently denied. You can enable it from app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
