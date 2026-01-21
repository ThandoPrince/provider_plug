class ClientAddressModel {
  final int? id;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final String? streetNumber;
  final String? route;
  final String? locality;
  final String? administrativeArea;
  final String? formattedAddress;
  final String? country;
  final String? postalCode;
  final String? addressType;

  ClientAddressModel({
    this.id,
    this.latitude,
    this.longitude,
    this.placeId,
    this.streetNumber,
    this.route,
    this.locality,
    this.administrativeArea,
    this.formattedAddress,
    this.country,
    this.postalCode,
    this.addressType,
  });

  factory ClientAddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ClientAddressModel();

    return ClientAddressModel(
      id: json['id'] as int?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      placeId: json['place_id']?.toString(),
      streetNumber: json['street_number']?.toString(),
      route: json['route']?.toString(),
      locality: json['locality']?.toString(),
      administrativeArea: json['administrative_area_level_1']?.toString(),
      formattedAddress: json['formatted_address']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postal_code']?.toString(),
      addressType: json['address_type']?.toString(),
    );
  }

  /// ✅ Added toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'street_number': streetNumber,
      'route': route,
      'locality': locality,
      'administrative_area_level_1': administrativeArea,
      'formatted_address': formattedAddress,
      'country': country,
      'postal_code': postalCode,
      'address_type': addressType,
    };
  }
}
