import 'package:flutter_application_2/common/models/models/service_groups.dart';

class ServiceModel {
  final int? serviceId;
  final String? serviceName;
  final String? description;
  final int? providerCount;
  final ServiceGroupModel? serviceGroup;

  ServiceModel({
    this.serviceId,
    this.serviceName,
    this.description,
    this.providerCount,
    this.serviceGroup,
  });

  factory ServiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceModel();

    return ServiceModel(
      serviceId: json['service_id'] is int
          ? json['service_id'] as int
          : int.tryParse(json['service_id']?.toString() ?? ''),
      serviceName: json['service_name'] as String?,
      description: json['description'] as String?,
      providerCount: json['provider_count'] is int
          ? json['provider_count'] as int
          : int.tryParse(json['provider_count']?.toString() ?? '0') ?? 0,
      serviceGroup: json['service_group'] != null &&
              json['service_group'] is Map<String, dynamic>
          ? ServiceGroupModel.fromJson(json['service_group'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'service_name': serviceName,
        'description': description,
        'provider_count': providerCount,
        'service_group': serviceGroup?.toJson(),
      };
}
