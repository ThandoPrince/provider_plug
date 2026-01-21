class NegotiationRound {
  final int? id;
  final int? negotiationId;
  final String? senderType;
  final double? offeredPrice;
  final String? message;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  NegotiationRound({
    this.id,
    this.negotiationId,
    this.senderType,
    this.offeredPrice,
    this.updatedAt,
    this.message,
    this.createdAt,
  });

  factory NegotiationRound.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NegotiationRound();

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

    return NegotiationRound(
      id: parseInt(json['id']),
      negotiationId: parseInt(json['negotiation']),
      senderType: json['sender_type'] as String?,
      offeredPrice: parseDouble(json['offered_price']),
      message: json['message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'updated_at': updatedAt?.toIso8601String(),
        'negotiation': negotiationId,
        'sender_type': senderType,
        'offered_price': offeredPrice,
        'message': message,
        'created_at': createdAt?.toIso8601String(),
      };
}
