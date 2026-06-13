import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class ConfirmSessionApi {
  // 1. Declare base configurations first to fix initialization ordering bugs
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // 2. Initialize Interceptors before loading the Dio engine configuration
  static final InterceptorsWrapper _authInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = _getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException error, handler) {
      if (kDebugMode) {
        print('❌ Dio Error Intercepted [${error.response?.statusCode}]: ${error.message}');
      }
      return handler.next(error);
    },
  );

  // 3. Instantiate Dio engine utilizing the pre-processed parameters above
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(_authInterceptor);

  /// GET HTTP Transaction Wrapper
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// POST HTTP Transaction Wrapper
  static Future<Response> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _dio.post(path, data: body);
  }

  /// PUT HTTP Transaction Wrapper
  static Future<Response> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _dio.put(path, data: body);
  }

  /// PATCH HTTP Transaction Wrapper
  static Future<Response> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _dio.patch(path, data: body);
  }

  /// DELETE HTTP Transaction Wrapper
  static Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  /// Extracts deep validation errors dropped by backend architectures safely
  static String extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['detail'] ?? data['message'] ?? 'Something went wrong';
    }
    return e.message ?? 'Network transaction error accrued.';
  }

  /// Pulls the active state token synchronously without asynchronous overhead
  static String? _getAccessToken() {
    return AuthSessionController.instance.accessToken;
  }
}