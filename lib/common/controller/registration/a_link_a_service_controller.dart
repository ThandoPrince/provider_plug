import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/services/a_link_service_api_.dart';

class ALinkServiceController extends ChangeNotifier {
  final ALinkServiceApi aLinkServiceApi = ALinkServiceApi();

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

    final result = await ALinkServiceApi.submitService(
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