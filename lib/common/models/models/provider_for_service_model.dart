import 'package:flutter_application_2/common/models/models/cost_of_service_model.dart';
import 'package:flutter_application_2/common/models/models/service_provider_model.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';

class ProviderServiceModel {
  final int? id;
  final ServiceProviderModel? provider;
  final ServiceModel? service;
  final bool? isPrimary;
  final CostOfServiceModel? costOfService;

  ProviderServiceModel({
    this.id,
    this.provider,
    this.service,
    this.isPrimary,
    this.costOfService,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProviderServiceModel();

    return ProviderServiceModel(
      id: json['id'] as int?,
      provider: json['provider'] is Map<String, dynamic>
          ? ServiceProviderModel.fromJson(json['provider'])
          : null,
      service: json['service'] is Map<String, dynamic>
          ? ServiceModel.fromJson(json['service'])
          : null,
      isPrimary: json['is_primary'] as bool?,
      costOfService: json['cost_of_service'] is Map<String, dynamic>
          ? CostOfServiceModel.fromJson(json['cost_of_service'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider?.toJson(),
      'service': service?.toJson(),
      'is_primary': isPrimary,
      'cost_of_service': costOfService?.toJson(),
    };
  }

  bool get hasCost => costOfService != null;

  int? get serviceId => service?.serviceId;

  @override
  String toString() {
    final providerName = provider?.fullName ?? "Unknown Provider";
    final serviceName = service?.serviceName ?? "Unknown Service";
    return "$providerName - $serviceName";
  }
}