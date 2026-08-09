class SPLiveLocationModel {
  final String? suburb;
  final String? city;
  final String? province;
  final DateTime? updatedAt;

  const SPLiveLocationModel({
    this.suburb,
    this.city,
    this.province,
    this.updatedAt,
  });

  factory SPLiveLocationModel.fromJson(Map<String, dynamic> json) {
    return SPLiveLocationModel(
      suburb: json['suburb'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suburb': suburb,
      'city': city,
      'province': province,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayLocation {
    final parts = [
      suburb,
      city,
      province,
    ].where((e) => e != null && e!.trim().isNotEmpty);

    return parts.join(", ");
  }
}