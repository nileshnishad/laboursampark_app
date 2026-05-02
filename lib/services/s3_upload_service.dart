// S3 credentials are injected at build time via --dart-define-from-file=dart_defines.json
// NEVER hardcode AWS credentials in source code.
// Run: flutter run --dart-define-from-file=dart_defines.json
//  or: flutter build web --dart-define-from-file=dart_defines.json

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class S3UploadService {
  static const String _region = String.fromEnvironment('S3_REGION', defaultValue: 'ap-southeast-2');
  static const String _bucket = String.fromEnvironment('S3_BUCKET', defaultValue: 'laboursampark');
  static const String _accessKeyId = String.fromEnvironment('AWS_ACCESS_KEY_ID');
  static const String _secretAccessKey = String.fromEnvironment('AWS_SECRET_ACCESS_KEY');
  static const String _service = 's3';

  static String get _host => '$_bucket.s3.$_region.amazonaws.com';

  /// Uploads [bytes] directly to S3 using AWS Signature V4.
  /// Returns the public URL on success, or null on failure.
  static Future<String?> upload({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    final now = DateTime.now().toUtc();
    final dateStamp = _fmtDate(now);   // YYYYMMDD
    final amzDate  = _fmtAmzDate(now); // YYYYMMDDTHHMMSSZ

    // Unique object key
    final ts  = now.millisecondsSinceEpoch;
    final ext = filename.contains('.') ? filename.split('.').last : 'jpg';
    final key = 'uploads/jobs/$ts.$ext';

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
      return null;
    } catch (_) {
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
}
