
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:http/http.dart' as http;

class ConfirmSessionApi {
  ConfirmSessionApi._();

  /// GET HTTP Transaction Wrapper
  static Future<http.Response> get(
    Uri url, {
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiClient.instance.request(
      (token) => http.get(
        url.replace(queryParameters: queryParameters),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  /// POST HTTP Transaction Wrapper
  static Future<http.Response> post(
    Uri url, {
    Object? body,
  }) {
    return ApiClient.instance.request(
      (token) => http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      ),
    );
  }

  /// PUT HTTP Transaction Wrapper
  static Future<http.Response> put(
    Uri url, {
    Object? body,
  }) {
    return ApiClient.instance.request(
      (token) => http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      ),
    );
  }

  /// PATCH HTTP Transaction Wrapper
  static Future<http.Response> patch(
    Uri url, {
    Object? body,
  }) {
    return ApiClient.instance.request(
      (token) => http.patch(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      ),
    );
  }

  /// DELETE HTTP Transaction Wrapper
  static Future<http.Response> delete(
    Uri url,
  ) {
    return ApiClient.instance.request(
      (token) => http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  static String extractError(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return "Something went wrong.";
  }
}