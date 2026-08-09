import 'package:flutter_application_2/common/models/models/cost_of_service_model.dart';
import 'package:flutter_application_2/common/models/models/service_provider_model.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';

class ProviderServiceModel {
  final int? id;
  final ServiceProviderModel? provider;
  final ServiceModel? service;
  final bool? isActive;
  final bool? isPrimary;
  final bool? hasUploadedAffidavit;
  final bool? isAffidavitVerified;
  final CostOfServiceModel? costOfService;
  final String? dateCreated;

  final int completedOrders;

  // NEW
  final double? averageRating;

  ProviderServiceModel({
    this.id,
    this.provider,
    this.service,
    this.isActive,
    this.isPrimary,
    this.hasUploadedAffidavit,
    this.dateCreated,
    this.isAffidavitVerified,
    this.costOfService,
    this.completedOrders = 0,
    this.averageRating,
  });

  factory ProviderServiceModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return ProviderServiceModel();

    return ProviderServiceModel(
      id: json['id'] as int?,

      completedOrders:
          (json['completed_orders'] as num?)?.toInt() ?? 0,

      averageRating: json['average_rating'] != null
          ? double.tryParse(
              json['average_rating'].toString(),
            )
          : null,
          dateCreated: json['date_created'],

      provider: json['provider'] is Map<String, dynamic>
          ? ServiceProviderModel.fromJson(json['provider'])
          : null,

      service: json['service'] is Map<String, dynamic>
          ? ServiceModel.fromJson(json['service'])
          : null,

      isActive: json['is_active'] as bool?,
      isPrimary: json['is_primary'] as bool?,
      hasUploadedAffidavit:
          json['has_uploaded_affidavit'] as bool?,
      isAffidavitVerified:
          json['is_affidavit_verified'] as bool?,

      costOfService:
          json['cost_of_service'] is Map<String, dynamic>
              ? CostOfServiceModel.fromJson(
                  json['cost_of_service'],
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider?.toJson(),
      'service': service?.toJson(),
      'is_active': isActive,
      'date_created': dateCreated,
      'is_primary': isPrimary,
      'has_uploaded_affidavit': hasUploadedAffidavit,
      'is_affidavit_verified': isAffidavitVerified,
      'cost_of_service': costOfService?.toJson(),

      'completed_orders': completedOrders,
      'average_rating': averageRating,
    };
  }

  bool get hasCost => costOfService != null;

  bool get affidavitUploaded =>
      hasUploadedAffidavit ?? false;

  bool get affidavitVerified =>
      isAffidavitVerified ?? false;

  bool get active => isActive ?? false;

  int? get serviceId => service?.serviceId;

  @override
  String toString() {
    final providerName =
        provider?.fullName ?? "Unknown Provider";
    final serviceName =
        service?.serviceName ?? "Unknown Service";
    return "$providerName - $serviceName";
  }
}