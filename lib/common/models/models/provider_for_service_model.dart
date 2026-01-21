import 'package:flutter_application_2/common/models/models/service_provider_model.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';

class ProviderServiceModel {
  final ServiceProviderModel? provider;
  final ServiceModel? service;

  ProviderServiceModel({
    this.provider,
    this.service,
  });

  /// Factory constructor to safely parse JSON
  factory ProviderServiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProviderServiceModel();

    return ProviderServiceModel(
      provider: (json['provider'] is Map<String, dynamic>)
          ? ServiceProviderModel.fromJson(json['provider'])
          : null,
      service: (json['service'] is Map<String, dynamic>)
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }

  /// Convert to JSON (for backend)
  Map<String, dynamic> toJson() {
    return {
      'provider': provider?.spProfile?.emailAddress,
      'service': service?.serviceId,
    };
  }

  @override
  String toString() {
    final providerName = provider?.fullName ?? "Unknown Provider";
    final serviceName = service?.serviceName ?? "Unknown Service";
    return "$providerName - $serviceName";
  }
}
