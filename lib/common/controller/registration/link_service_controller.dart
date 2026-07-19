import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/services/link_service_api.dart';

class LinkServiceController extends ChangeNotifier {
  final LinkServiceApi linkServiceApi = LinkServiceApi();

  bool isLoading = false;
  String? message;

  Map<String, dynamic>? lastServiceResponse;

  /// Stores the ProviderService ID returned by the backend
  String? providerServiceId;

  /// Submit a service
  Future<bool> submitService({
   
    required String serviceName,
    String description = '',
    String? serviceGroupId,
  }) async {
    isLoading = true;
    message = null;
    lastServiceResponse = null;
    providerServiceId = null;
    notifyListeners();

    final result = await LinkServiceApi.submitService(
      serviceName: serviceName,
      description: description,
      serviceGroupId: serviceGroupId,
    );

    isLoading = false;

    if (result["success"]) {
      // Save the ProviderService ID
      providerServiceId = result["id"]?.toString();

      lastServiceResponse = {
        "status": result["status"],
        "service": result["service"],
      };

      notifyListeners();
      return true;
    } else {
      message = result["message"];
      notifyListeners();
      return false;
    }
  }
}