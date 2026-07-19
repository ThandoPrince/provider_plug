import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/service_groups.dart';

class FetchServiceByGroupApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches all available service groups from the system index.
  static Future<List<ServiceGroupModel>> fetchServiceGroups() async {
    final uri = Uri.parse('$baseUrl/service_groups/');

    try {
      final response = await ApiClient.instance.request(
        (token) => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return decodedData
              .map(
                (json) => ServiceGroupModel.fromJson(
                  Map<String, dynamic>.from(json as Map),
                ),
              )
              .toList();
        }

        throw const FormatException(
          'Expected an array schema layout for service groups.',
        );
      } else {
        if (kDebugMode) {
          print(
            '❌ SERVICE GROUPS LOAD FAILED [${response.statusCode}]: ${response.body}',
          );
        }

        throw Exception(
          'Server rejected service groups fetch with status: [${response.statusCode}]',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in fetchServiceGroups: $e');
      }

      throw Exception(
        'Network or formatting error parsing service groupings: $e',
      );
    }
  }
}