/// Shared travel mode enum. Kept in its own tiny file (rather than inside
/// google_map_controller.dart or directions_service.dart) so both can import
/// it without creating a circular dependency between them.
enum TravelMode { car, pedestrian, bicycle, scooter }

TravelMode travelModeFromString(String? mode) {
  switch ((mode ?? 'car').toLowerCase()) {
    case 'pedestrian':
      return TravelMode.pedestrian;
    case 'bicycle':
      return TravelMode.bicycle;
    case 'scooter':
      return TravelMode.scooter;
    case 'car':
    default:
      return TravelMode.car;
  }
}

String travelModeToApiString(TravelMode mode) {
  switch (mode) {
    case TravelMode.car:
      return 'driving';
    case TravelMode.pedestrian:
      return 'walking';
    case TravelMode.bicycle:
      return 'bicycling';
    case TravelMode.scooter:
      // The Directions API has no "scooter" mode. `two_wheeler` exists but is
      // only supported in a handful of countries (mainly India), so we fall
      // back to bicycling everywhere else. Swap this if your users are in a
      // two_wheeler-supported region.
      return 'bicycling';
  }
}