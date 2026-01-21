import 'package:flutter_application_2/common/models/models/client_models/client_address_model.dart';
import 'package:flutter_application_2/common/models/models/client_models/clients_details.dart';

class AddressClientModel {
  final int? id;
  final ClientModel? client;
  final ClientAddressModel? address;
  final bool? isOwner;
  final bool? houseAdministrator;
  final bool? isSuperUser;
  final String? addressType;
  bool? isDefault;
  final bool? isVerified;

  AddressClientModel({
    this.id,
    this.client,
    this.address,
    this.isOwner,
    this.houseAdministrator,
    this.isSuperUser,
    this.addressType,
    this.isDefault,
    this.isVerified,
  });

  factory AddressClientModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AddressClientModel();
    }

    // Deduplicate clients from address.clients
    List<dynamic> uniqueClientsJson = [];
    final seenEmails = <String>{};
    final clientsJson = (json['address']?['clients'] as List<dynamic>?) ?? [];
    for (var c in clientsJson) {
      final email = c['client_profile']?['email_address'] as String?;
      if (email != null && !seenEmails.contains(email)) {
        uniqueClientsJson.add(c);
        seenEmails.add(email);
      }
    }

    final addressJson = Map<String, dynamic>.from(json['address'] ?? {});
    addressJson['clients'] = uniqueClientsJson;

    return AddressClientModel(
      id: json['id'] as int?,
      client: json['client'] != null
          ? ClientModel.fromJson(json['client'] as Map<String, dynamic>?)
          : null,
      address: ClientAddressModel.fromJson(addressJson),
      isOwner: json['is_owner'] as bool?,
      houseAdministrator: json['house_administrator'] as bool?,
      isSuperUser: json['is_super_user'] as bool?,
      addressType: json['address_type'] as String?,
      isDefault: json['is_default'] as bool?,
      isVerified: json['is_verified'] as bool?,
    );
  }
}
