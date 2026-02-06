import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';

// Convert GeoCoordinates to Position (all required fields)
Position positionFromGeo(GeoCoordinates coords) {
  return Position(
    latitude: coords.latitude,
    longitude: coords.longitude,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,    // <-- required
    heading: 0.0,
    headingAccuracy: 0.0,     // <-- required
    speed: 0.0,
    speedAccuracy: 0.0,
  );
}
