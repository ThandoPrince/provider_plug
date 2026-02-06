import 'session_model.dart';

class SessionLocationPingModel {
  final int? pingId;
  final SessionModel? session;

  final double? latitude;
  final double? longitude;
  final double? accuracy;
 

  final bool? insideGeofence;
  final double? distanceFromSiteMeters;

  final DateTime? createdAt;

  const SessionLocationPingModel({
    this.pingId,
    this.session,
    this.latitude,
    this.longitude,
    this.accuracy,
    
    this.insideGeofence,
    this.distanceFromSiteMeters,
    this.createdAt,
  });

  /* ---------------- JSON ---------------- */

  factory SessionLocationPingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SessionLocationPingModel();

    return SessionLocationPingModel(
      pingId: json['ping_id'] as int?,
      session: json['session'] is Map<String, dynamic>
          ? SessionModel.fromJson(json['session'] as Map<String, dynamic>)
          : null,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      accuracy: _toDouble(json['accuracy']),
     
      insideGeofence: json['inside_geofence'] as bool?,
      distanceFromSiteMeters: _toDouble(json['distance_from_site_meters']),
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
       
      };

  /* ---------------- Helpers ---------------- */

  bool get isOutsideGeofence => insideGeofence == false;

  static double? _toDouble(dynamic value) => value is num ? value.toDouble() : null;
}
