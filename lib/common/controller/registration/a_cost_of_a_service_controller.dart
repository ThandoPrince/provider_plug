import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/a_cost_of_service_add_api.dart';





class ACostOfServiceController extends ChangeNotifier {
  final ACostOfServiceApi api = ACostOfServiceApi();

  bool isLoading = false;
  String? errorMessage;
  double? updatedCost;
  int? costId;



  Future<bool> updateServiceCost({
    required String notes,
   
    required int serviceId,
    required double cost,
    String? token,
    List<File> images = const [],
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

     

      final response = await ACostOfServiceApi.updateServiceCost(
     
        serviceId: serviceId,
        cost: cost,
     
        notes: notes,
      );

      final costData = response["cost_of_service"] as Map<String, dynamic>?;

      if (costData == null) {
        throw Exception("Cost of service data was not returned.");
      }

      costId = costData["id"] as int?;
      updatedCost = double.tryParse(costData["base_price"]?.toString() ?? "");

      if (costId == null) {
        throw Exception("Cost ID was not returned.");
      }

      if (images.isNotEmpty) {
        await ACostOfServiceApi.uploadServiceImages(
          costId: costId!,
          images: images,
          
        );
      }

      
      

      

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  
 


  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {

    super.dispose();
  }
}