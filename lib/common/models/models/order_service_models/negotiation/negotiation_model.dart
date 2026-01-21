import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';

class NegotiationModel {
  final int? negotiationId;
  final int? serviceOrderId; 
  final int? providerForNegotiationId; 

  final double? basePrice;
  final double? proposedPrice;
  final double? providerResponsePrice;

  final String? status; 
  final String? lastResponder; 

  final int? roundCount;
  final int? maxRounds;
  final DateTime? createdAt;

  final List<NegotiationRound>? rounds; // Nullable rounds

  NegotiationModel({
    this.negotiationId,
    this.serviceOrderId,
    this.providerForNegotiationId,
    this.basePrice,
    this.proposedPrice,
    this.providerResponsePrice,
    this.status,
    this.lastResponder,
    this.roundCount,
    this.maxRounds,
    this.createdAt,
    this.rounds,
  });

 factory NegotiationModel.fromJson(Map<String, dynamic> json) {
  double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  return NegotiationModel(
    negotiationId: parseInt(json['negotiation_id']),
    serviceOrderId: parseInt(json['service_order']),
    providerForNegotiationId: parseInt(json['provider_for_negotiation']?['id']),
    basePrice: parseDouble(json['base_price']),
    proposedPrice: parseDouble(json['proposed_price']),
    providerResponsePrice: parseDouble(json['provider_response_price']),
    status: json['status'] as String?,
    lastResponder: json['last_responder'] as String?,
    roundCount: parseInt(json['round_count']),
    maxRounds: parseInt(json['max_rounds']),
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
    rounds: (json['rounds'] as List<dynamic>?)
        ?.map((r) => NegotiationRound.fromJson(r as Map<String, dynamic>))
        .toList(),
  );
}
}