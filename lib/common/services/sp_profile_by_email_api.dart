import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/sp_details_model.dart';

class SpProfileByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single service provider profile matching a specific email address
  static Future<ServiceProviderModel> fetchSpProfileByEmail(String email) async {
    final providerID = AuthSessionController.instance.id;
    final url = Uri.parse('$baseUrl/service_provider_my/$providerID/');
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is Map) {
          return ServiceProviderModel.fromJson(Map<String, dynamic>.from(decodedData));
        }
        throw const FormatException('Expected a map object response for single profile.');
      } else {
        if (kDebugMode) {
          print('❌ Profile load failure [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Failed to load profile context [${response.statusCode}].');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in fetchSpProfileByEmail: $e');
      }
      throw Exception('Network or formatting error parsing service provider profile: $e');
    }
  }

  /// GET: Fetches all registered service provider profiles
  static Future<List<ServiceProviderModel>> fetchSpProfile() async {
    final url = Uri.parse('$baseUrl/service_providers/');
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((item) => ServiceProviderModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        throw const FormatException('Expected an array layout response for multiple profiles.');
      } else {
        if (kDebugMode) {
          print('❌ Profiles bulk load failure [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Failed to load bulk profiles list [${response.statusCode}].');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in fetchSpProfile: $e');
      }
      throw Exception('Network error or structural layout exception tracking provider indices: $e');
    }
  }
}