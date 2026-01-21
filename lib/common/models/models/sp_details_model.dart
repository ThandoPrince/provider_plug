import 'package:flutter_application_2/common/models/models/client_models/address_client_model.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';
import 'package:flutter_application_2/common/models/models/sp_address_model.dart';
import 'package:flutter_application_2/common/models/models/sp_profile_model.dart' show SPProfileModel;

class ServiceProviderModel {
  final SPProfileModel spProfile;
  final String fullName;
  final String gender;
  final String idNumber;
  final String spDescription;
  final DateTime? dob; 
  final String mobileNumber;
  final SpAddressModel? location;
  final List<ServiceModel> services;
  final double rating; 
  final String profileImage;
  final bool isActive;
  final bool isDiscoverable;

  ServiceProviderModel({
    required this.spProfile,
    required this.fullName,
    required this.gender,
    required this.idNumber,
    required this.spDescription,
    required this.dob,
    required this.mobileNumber,
    this.location,
    required this.services,
    required this.rating,
    required this.profileImage,

    // ✅ New required params
    required this.isActive,
    required this.isDiscoverable,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      spProfile: SPProfileModel.fromJson(
        json['sp_profile'] as Map<String, dynamic>? ?? {},
      ),
      fullName: json['full_name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      idNumber: json['id_number'] as String? ?? '',
      spDescription: json['sp_description'] as String? ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      mobileNumber: json['mobile_number'] as String? ?? '',
      location: json['location'] != null
          ? SpAddressModel.fromJson(json['location'])
          : null,
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      profileImage: json['profile_image'] as String? ?? '',

      // ✅ Parse new fields from backend
      isActive: json['is_active'] as bool? ?? false,
      isDiscoverable: json['is_discoverable'] as bool? ?? false,
    );
  }

  String get fullProfileImageUrl =>
      profileImage.isNotEmpty ? "http://192.168.18.64:8000$profileImage" : "";
}
