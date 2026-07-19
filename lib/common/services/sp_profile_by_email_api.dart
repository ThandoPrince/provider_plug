import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/models/models/sp_details_model.dart';

class SpProfileByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single service provider profile matching a specific email address
  static Future<ServiceProviderModel> fetchSpProfileByEmail(
   
  ) async {
    final providerID = AuthSessionController.instance.id;

    try {
      final response = await ApiClient.instance.request(
        (token) => http.get(
          Uri.parse(
            '$baseUrl/service_provider_my/$providerID/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is Map) {
          return ServiceProviderModel.fromJson(
            Map<String, dynamic>.from(decodedData),
          );
        }

        throw const ApiException(
          'Invalid response format received from the server.',
        );
      }

      if (kDebugMode) {
        print(
          '❌ Profile load failure [${response.statusCode}]: ${response.body}',
        );
      }

      throw ApiException(
        'Failed to load profile [${response.statusCode}].',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response format received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ fetchSpProfileByEmail: $e');
      }

      throw const ApiException(
        'Failed to load service provider profile.',
      );
    }
  }

  /// GET: Fetches all registered service provider profiles
  static Future<List<ServiceProviderModel>> fetchSpProfile() async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http.get(
          Uri.parse(
            '$baseUrl/service_providers/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return decodedData
              .map(
                (item) => ServiceProviderModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();
        }

        throw const ApiException(
          'Invalid response format received from the server.',
        );
      }

      if (kDebugMode) {
        print(
          '❌ Profiles bulk load failure [${response.statusCode}]: ${response.body}',
        );
      }

      throw ApiException(
        'Failed to load service providers [${response.statusCode}].',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response format received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ fetchSpProfile: $e');
      }

      throw const ApiException(
        'Failed to load service providers.',
      );
    }
  }
}