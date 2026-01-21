class LiveLocationModel {
  final double? latitude;
  final double? longitude;
  final DateTime? updatedAt;
  final String? status; // optional (e.g., 'active', 'offline', etc.)

  LiveLocationModel({
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.status,
  });

  factory LiveLocationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LiveLocationModel();

    return LiveLocationModel(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      if (status != null) 'status': status,
    };
  }
}
