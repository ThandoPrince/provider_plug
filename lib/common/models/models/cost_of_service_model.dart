import 'service_provider_model.dart';
import 'services_model.dart';

class CostOfServiceModel {
  final int? id;
  final ServiceModel service;
  final ServiceProviderModel provider;
  final double? basePrice;
  final bool negotiable;
  final String? notes;

  CostOfServiceModel({
    this.id,
    required this.service,
    required this.provider,
    this.basePrice,
    required this.negotiable,
    this.notes,
  });

  factory CostOfServiceModel.fromJson(Map<String, dynamic> json) {
    return CostOfServiceModel(
      id: json['id'],
      service: ServiceModel.fromJson(json['service']),
      provider: ServiceProviderModel.fromJson(json['provider']),
      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
      negotiable: json['negotiable'] ?? true,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'provider': provider.toJson(),
      'base_price': basePrice,
      'negotiable': negotiable,
      'notes': notes,
    };
  }
}
