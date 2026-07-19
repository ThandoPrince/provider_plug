enum RoundLocalStatus { confirmed, sending, failed }

class NegotiationRound {
  final int? id;
  final int? negotiationId;
  final String? senderType;
  final double? offeredPrice;
  final String? message;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  /// Client-only fields — never sent to or parsed from the API.
  /// Default to "confirmed" so anything built via fromJson() behaves
  /// exactly as it did before this change.
  final String? localId;
  final RoundLocalStatus localStatus;

  NegotiationRound({
    this.id,
    this.negotiationId,
    this.senderType,
    this.offeredPrice,
    this.updatedAt,
    this.message,
    this.createdAt,
    this.localId,
    this.localStatus = RoundLocalStatus.confirmed,
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
      // localId/localStatus intentionally omitted here — they default to
      // null / confirmed, since anything coming from the server is by
      // definition confirmed.
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
        // localId/localStatus deliberately NOT serialized — the backend
        // has no concept of them.
      };

  NegotiationRound copyWith({
    int? id,
    int? negotiationId,
    String? senderType,
    double? offeredPrice,
    String? message,
    DateTime? updatedAt,
    DateTime? createdAt,
    String? localId,
    RoundLocalStatus? localStatus,
  }) {
    return NegotiationRound(
      id: id ?? this.id,
      negotiationId: negotiationId ?? this.negotiationId,
      senderType: senderType ?? this.senderType,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      message: message ?? this.message,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      localId: localId ?? this.localId,
      localStatus: localStatus ?? this.localStatus,
    );
  }

  bool get isPending => localStatus == RoundLocalStatus.sending;
  bool get isFailed => localStatus == RoundLocalStatus.failed;
}