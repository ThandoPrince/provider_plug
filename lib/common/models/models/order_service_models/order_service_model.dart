import 'package:flutter_application_2/common/models/models/client_models/client_address_model.dart';
import 'package:flutter_application_2/common/models/models/client_models/client_auth.dart';
import 'package:flutter_application_2/common/models/models/client_models/clients_details.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_pictures_model.dart';
import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';
import 'package:flutter_application_2/common/models/models/service_groups.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';

class OrderService {
  final int? orderId;
  final String? title;
  final double? basePrice;
  final double? finalPrice;
  final bool? isNegotiated;
  final ClientModel? client;
  final String? description;
  final ProviderServiceModel? providerForService; // <-- now object
  final DateTime? requestedDateTime;
  final double? proposalPrice;
  final DateTime? requestedDate;
  final String? notes;
  final ClientAddressModel? deliveryAddress;
  final DateTime? dateAndTimeCreated;
  final String? status;
  final bool? isBroadcasted;
  final List<String>? invitedProviders;
  final double? totalPrice;
  final ServiceModel? serviceRequired;
  final List<OrderPictureModel>? orderPictures;

  OrderService({
    this.orderId,
    this.title,
    this.basePrice,
    this.finalPrice,
    this.isNegotiated,
    this.client,
    this.description,
    this.providerForService,
    this.requestedDateTime,
    this.proposalPrice,
    this.requestedDate,
    this.notes,
    this.deliveryAddress,
    this.dateAndTimeCreated,
    this.status,
    this.isBroadcasted,
    this.invitedProviders,
    this.totalPrice,
    this.serviceRequired,
    this.orderPictures,
  });

  factory OrderService.fromJson(Map<String, dynamic>? json) {
    if (json == null) return OrderService();

    // Parse requested date
    DateTime? requestedDate = json['requested_date'] != null
        ? DateTime.tryParse(json['requested_date'])
        : null;

    // Parse requested time into DateTime
    DateTime? requestedDateTime;
    if (json['requested_date_time'] != null) {
      try {
        if (requestedDate != null) {
          final parts = json['requested_date_time'].split(':');
          requestedDateTime = DateTime(
            requestedDate.year,
            requestedDate.month,
            requestedDate.day,
            int.tryParse(parts[0]) ?? 0,
            int.tryParse(parts[1]) ?? 0,
            int.tryParse(parts[2]) ?? 0,
          );
        } else {
          requestedDateTime =
              DateTime.tryParse("1970-01-01 ${json['requested_date_time']}");
        }
      } catch (_) {
        requestedDateTime = null;
      }
    }

    // Client
    ClientModel? clientModel;
    if (json['client'] != null) {
      if (json['client'] is String) {
        clientModel = ClientModel(
          clientProfile: ClientAuthModel(emailAddress: json['client']),
        );
      } else if (json['client'] is Map<String, dynamic>) {
        clientModel = ClientModel.fromJson(json['client']);
      }
    }

    // Service Required
    ServiceModel? serviceModel;
    if (json['service_required'] != null) {
      if (json['service_required'] is Map<String, dynamic>) {
        serviceModel = ServiceModel.fromJson(json['service_required']);
      } else if (json['service_required'] is int) {
        serviceModel = ServiceModel(
          serviceId: json['service_required'],
          serviceName: "",
          description: null,
          providerCount: 0,
          serviceGroup: ServiceGroupModel(groupId: "", name: ""),
        );
      }
    }

    // Provider For Service
    ProviderServiceModel? provider;
    if (json['provider_for_service'] != null &&
        json['provider_for_service'] is Map<String, dynamic>) {
      provider = ProviderServiceModel.fromJson(json['provider_for_service']);
    }

    // Order Pictures
    List<OrderPictureModel>? orderPictures;
    if (json['service_pictures'] != null && json['service_pictures'] is List) {
      orderPictures = (json['service_pictures'] as List)
          .map((pic) => OrderPictureModel.fromJson(pic))
          .toList();
    }

    // Invited Providers
    List<String>? invitedProviders;
    if (json['invited_providers'] != null && json['invited_providers'] is List) {
      invitedProviders = (json['invited_providers'] as List)
          .map((p) =>
              p?['provider']?['sp_profile']?['email_address']?.toString())
          .whereType<String>()
          .toList();
    }

    return OrderService(
      orderId: json['order_id'] as int?,
      title: json['title'] as String?,
      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
      finalPrice: json['final_price'] != null
          ? double.tryParse(json['final_price'].toString())
          : null,
      isNegotiated: json['is_negotiated'] as bool?,
      client: clientModel,
      description: json['description'] as String?,
      providerForService: provider, // <-- assigned object
      requestedDateTime: requestedDateTime,
      proposalPrice: json['proposal_price'] != null
          ? double.tryParse(json['proposal_price'].toString())
          : null,
      requestedDate: requestedDate,
      notes: json['notes'] as String?,
      deliveryAddress: json['delivery_address'] != null
          ? ClientAddressModel.fromJson(json['delivery_address'])
          : null,
      dateAndTimeCreated: json['date_and_time_created'] != null
          ? DateTime.tryParse(json['date_and_time_created'])
          : null,
      status: json['status'] as String?,
      isBroadcasted: json['is_broadcasted'] as bool?,
      invitedProviders: invitedProviders,
      totalPrice: json['total_price'] != null
          ? double.tryParse(json['total_price'].toString())
          : null,
      serviceRequired: serviceModel,
      orderPictures: orderPictures,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'title': title,
        'base_price': basePrice,
        'final_price': finalPrice,
        'is_negotiated': isNegotiated,
        'client': client?.toJson(),
        'description': description,
        'provider_for_service': providerForService?.toJson(),
        'requested_date_time': requestedDateTime?.toIso8601String(),
        'proposal_price': proposalPrice,
        'requested_date': requestedDate?.toIso8601String(),
        'notes': notes,
        'delivery_address': deliveryAddress?.toJson(),
        'date_and_time_created': dateAndTimeCreated?.toIso8601String(),
        'status': status,
        'is_broadcasted': isBroadcasted,
        'invited_providers': invitedProviders,
        'total_price': totalPrice,
        'service_required': serviceRequired?.toJson(),
        'service_pictures':
            orderPictures?.map((picture) => picture.toJson()).toList(),
      };
}
