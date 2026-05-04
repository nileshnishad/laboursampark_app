// S3 credentials are loaded from lib/core/secrets.dart (gitignored).
// NEVER hardcode credentials directly in this file or commit secrets.dart.

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:laboursampark_app/core/secrets.dart';

class S3UploadService {
  static const String _region = kS3Region;
  static const String _bucket = kS3Bucket;
  static const String _accessKeyId = kAwsAccessKeyId;
  static const String _secretAccessKey = kAwsSecretAccessKey;
  static const String _service = 's3';

  static String get _host => '$_bucket.s3.$_region.amazonaws.com';

  /// Uploads [bytes] directly to S3 using AWS Signature V4.
  /// Returns the public URL on success, or null on failure.
  static Future<String?> upload({
    required Uint8List bytes,
    required String filename,
    required String contentType,
    String folder = 'uploads/jobs', // e.g. 'labour' for profile photos
  }) async {
    final now = DateTime.now().toUtc();
    final dateStamp = _fmtDate(now);   // YYYYMMDD
    final amzDate  = _fmtAmzDate(now); // YYYYMMDDTHHMMSSZ

    // Unique object key — normalize extension from content-type to avoid mismatch
    final ts  = now.millisecondsSinceEpoch;
    final ext = _extFromContentType(contentType);
    final key = '$folder/$ts.$ext';

    final payloadHash = _sha256Hex(bytes);

    // Canonical headers — keys must be lowercase and sorted
    final signedHeaderNames = ['content-type', 'host', 'x-amz-content-sha256', 'x-amz-date'];
    final headerValues = {
      'content-type':        contentType,
      'host':                _host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date':          amzDate,
    };
    final canonicalHeaders =
        signedHeaderNames.map((k) => '$k:${headerValues[k]!}\n').join();
    final signedHeaders = signedHeaderNames.join(';');

    // Build canonical request
    final canonicalRequest = [
      'PUT',
      '/$key',
      '', // no query string
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    // String to sign
    final credentialScope = '$dateStamp/$_region/$_service/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      _sha256HexStr(canonicalRequest),
    ].join('\n');

    // Derive signing key and calculate signature
    final signingKey = _signingKey(dateStamp);
    final signature  = _hmacHex(signingKey, stringToSign);

    final authorization =
        'AWS4-HMAC-SHA256 Credential=$_accessKeyId/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    try {
      final response = await Dio().put<dynamic>(
        'https://$_host/$key',
        data: bytes,
        options: Options(
          headers: {
            'Content-Type':          contentType,
            'x-amz-date':            amzDate,
            'x-amz-content-sha256':  payloadHash,
            'Authorization':         authorization,
          },
          // Don't set Content-Length — browser (XHR) sets it automatically
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      if (response.statusCode != null && response.statusCode! < 400) {
        return 'https://$_host/$key';
      }
      debugPrint('[S3] Upload failed — status: ${response.statusCode}, body: ${response.data}');
      return null;
    } on DioException catch (e) {
      debugPrint('[S3] DioException: ${e.response?.statusCode} ${e.response?.data} | ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[S3] Unknown error: $e');
      return null;
    }
  }

  // ── Signature V4 helpers ────────────────────────────────────────────────

  static String _fmtDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}';

  static String _fmtAmzDate(DateTime dt) =>
      '${_fmtDate(dt)}T'
      '${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}Z';

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static String _sha256Hex(List<int> data) => _hex(sha256.convert(data).bytes);

  static String _sha256HexStr(String data) => _sha256Hex(utf8.encode(data));

  static List<int> _hmac(List<int> key, String data) =>
      Hmac(sha256, key).convert(utf8.encode(data)).bytes;

  static String _hmacHex(List<int> key, String data) => _hex(_hmac(key, data));

  static List<int> _signingKey(String dateStamp) {
    final kDate    = _hmac(utf8.encode('AWS4$_secretAccessKey'), dateStamp);
    final kRegion  = _hmac(kDate, _region);
    final kService = _hmac(kRegion, _service);
    return _hmac(kService, 'aws4_request');
  }

  /// Maps content-type to a safe S3 file extension.
  static String _extFromContentType(String contentType) {
    switch (contentType) {
      case 'image/png':  return 'png';
      case 'image/webp': return 'webp';
      case 'image/gif':  return 'gif';
      default:           return 'jpg'; // image/jpeg + HEIC (already converted)
    }
  }
}
