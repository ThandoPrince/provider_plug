import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfirmSessionApi {
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

  /// 🔐 CHANGE THIS
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// =========================
  /// AUTH INTERCEPTOR
  /// =========================
  static final InterceptorsWrapper _authInterceptor =
      InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) {
      return handler.next(error);
    },
  );



  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  static Future<Response> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _dio.post(
      path,
      data: body,
    );
  }
  static String extractError(DioException e) {
  if (e.response?.data is Map) {
    return e.response?.data['detail'] ??
        e.response?.data['message'] ??
        'Something went wrong';
  }
  return e.message ?? 'Network error';
}

  static Future<Response> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _dio.put(
      path,
      data: body,
    );
  }

  static Future<Response> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _dio.patch(
      path,
      data: body,
    );
  }

  static Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  /// =========================
  /// TOKEN HANDLING (PLUG IN YOUR STORAGE)
  /// =========================

  static Future<String?> _getAccessToken() async {
    // Example:
    // return await SecureStorage.read("access_token");

    return null;
  }
}
