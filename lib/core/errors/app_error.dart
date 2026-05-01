import 'package:dio/dio.dart';

import 'error_messages.dart';

class AppError {
  final String userMessage;

  const AppError(this.userMessage);

  factory AppError.fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppError(ErrorMessages.timeout);
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return const AppError(ErrorMessages.noInternet);
    }

    final statusCode = e.response?.statusCode ?? 0;
    switch (statusCode) {
      case 400:
        return const AppError(ErrorMessages.badRequest);
      case 401:
        return const AppError(ErrorMessages.unauthorized);
      case 403:
        return const AppError(ErrorMessages.forbidden);
      case 404:
        return const AppError(ErrorMessages.notFound);
      case 500:
      case 502:
      case 503:
      case 504:
        return const AppError(ErrorMessages.serverError);
      default:
        return const AppError(ErrorMessages.unknown);
    }
  }
}
