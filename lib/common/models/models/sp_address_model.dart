

class SpAddressModel {
  final int id;
  final String? streetNumber;
  final String? route;
  final String? locality;
  final String? administrativeAreaLevel1;
  final String? formattedAddress;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  SpAddressModel({
    required this.id,
    this.streetNumber,
    this.route,
    this.locality,
    this.administrativeAreaLevel1,
    this.formattedAddress,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  factory SpAddressModel.fromJson(Map<String, dynamic> json) {
    return SpAddressModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      streetNumber: json['street_number']?.toString(),
      route: json['route']?.toString(),
      locality: json['locality']?.toString(),
      administrativeAreaLevel1: json['administrative_area_level_1']?.toString(),
      formattedAddress: json['formatted_address']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postal_code']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      placeId: json['place_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'street_number': streetNumber,
        'route': route,
        'locality': locality,
        'administrative_area_level_1': administrativeAreaLevel1,
        'formatted_address': formattedAddress,
        'country': country,
        'postal_code': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'place_id': placeId,
      };
}
