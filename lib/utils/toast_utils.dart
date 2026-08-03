import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ToastUtils {
  static Future<void> _showMessage(
    String message, {
    required Color backgroundColor,
  }) async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
      Get.snackbar(
        '',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        snackStyle: SnackStyle.FLOATING,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor,
        textColor: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        '',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        snackStyle: SnackStyle.FLOATING,
        duration: const Duration(seconds: 2),
      );
    }
  }

  static void showError(String message) {
    _showMessage(message, backgroundColor: Colors.redAccent);
  }

  static void showSuccess(String message) {
    _showMessage(message, backgroundColor: Colors.green);
  }

  static void showInfo(String message) {
    _showMessage(message, backgroundColor: Colors.blue);
  }
}
