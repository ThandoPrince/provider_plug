import 'package:flutter_application_2/common/models/models/cost_of_service_model.dart';
import 'sp_address_model.dart';
import 'sp_profile_model.dart';
import 'services_model.dart';

class ServiceProviderModel {
  final double? rating;
  final String? description;
  final String? profileImage;
  final String? fullName;
  final String? idNumber;
  final String? gender;
  final String? dob;
  final String? mobileNumber;
  final SpAddressModel? location; // nullable
  final SPProfileModel? spProfile; // nullable for safety
  final List<ServiceModel> services;
  final List<CostOfServiceModel> costOfServices;

  ServiceProviderModel({
    this.rating,
    this.description,
    this.profileImage,
    this.fullName,
    this.idNumber,
    this.gender,
    this.dob,
    this.mobileNumber,
    this.location,
    this.spProfile,
    List<ServiceModel>? services,
    List<CostOfServiceModel>? costOfServices,
  })  : services = services ?? [],
        costOfServices = costOfServices ?? [];

  factory ServiceProviderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServiceProviderModel();

    return ServiceProviderModel(
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      description: json['sp_description']?.toString(),
      profileImage: json['profile_image']?.toString(),
      gender: json['gender']?.toString(),
      fullName: json['full_name']?.toString(),
      idNumber: json['id_number']?.toString(),
      dob: json['dob']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      location: (json['location'] is Map<String, dynamic>)
          ? SpAddressModel.fromJson(json['location'])
          : null,
      spProfile: (json['sp_profile'] is Map<String, dynamic>)
          ? SPProfileModel.fromJson(json['sp_profile'])
          : null,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
      costOfServices: (json['cost_of_services'] as List<dynamic>?)
              ?.map((e) => CostOfServiceModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (gender != null) 'gender': gender,
      if (description != null) 'description': description,
      if (fullName != null) 'full_name': fullName,
      if (idNumber != null) 'id_number': idNumber,
      if (dob != null) 'dob': dob,
      if (mobileNumber != null) 'mobile_number': mobileNumber,
      if (rating != null) 'rating': rating,
      if (profileImage != null) 'profile_image': profileImage,
      if (location != null) 'location': location!.toJson(),
      if (spProfile != null) 'sp_profile': spProfile!.toJson(),
      'services': services.map((s) => s.toJson()).toList(),
      'cost_of_services': costOfServices.map((c) => c.toJson()).toList(),
    };
  }
}
