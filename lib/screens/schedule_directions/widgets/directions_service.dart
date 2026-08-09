import 'dart:convert';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_route_conversion.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';


/// Replaces `here.Route`. Everything the screens need out of a calculated
/// route lives here: the polyline to draw, the bounds to zoom to, the
/// distance/duration, and turn-by-turn steps for the maneuver card.
class AppRoute {
  final List<LatLng> polylinePoints;
  final LatLngBounds bounds;
  final double distanceMeters;
  final int durationSeconds;
  final List<AppRouteStep> steps;
  final LatLng origin;
  final LatLng destination;

  const AppRoute({
    required this.polylinePoints,
    required this.bounds,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.steps,
    required this.origin,
    required this.destination,
  });
}

/// Replaces `here.Maneuver`.
class AppRouteStep {
  final String instruction;
  final LatLng location;
  final double distanceMeters;

  const AppRouteStep({
    required this.instruction,
    required this.location,
    required this.distanceMeters,
  });
}

class DirectionsService {
  /// Pass your key explicitly, or provide it at build time with
  /// `--dart-define=GOOGLE_MAPS_API_KEY=xxx` and it'll be picked up here.
  ///
  /// NOTE: calling the Directions API directly from the client embeds your
  /// key in the app. For production, consider proxying this call through
  /// your own backend so the key never ships in the APK/IPA and so you can
  /// rate-limit/cache it (Directions API is billed per request, unlike
  /// HERE's on-device routing engine).
  final String apiKey;

    DirectionsService({String? apiKey})
      : apiKey = apiKey ??
            dotenv.env['GOOGLE_API_KEY'] ??
            '';

  Future<AppRoute?> getRoute({
    required LatLng origin,
    required LatLng destination,
    required TravelMode mode,
  }) async {
    if (apiKey.isEmpty) {
      throw StateError(
        'DirectionsService: no API key configured. Pass one in, or build '
        'with --dart-define=GOOGLE_MAPS_API_KEY=your_key',
      );
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': travelModeToApiString(mode),
      'key': apiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') return null;

    final routes = data['routes'] as List;
    if (routes.isEmpty) return null;

    final routeJson = routes.first as Map<String, dynamic>;
    final legs = routeJson['legs'] as List;
    if (legs.isEmpty) return null;

    final polylinePoints =
        decodePolyline(routeJson['overview_polyline']['points'] as String);

    final boundsJson = routeJson['bounds'] as Map<String, dynamic>;
    final bounds = LatLngBounds(
      southwest: LatLng(
        (boundsJson['southwest']['lat'] as num).toDouble(),
        (boundsJson['southwest']['lng'] as num).toDouble(),
      ),
      northeast: LatLng(
        (boundsJson['northeast']['lat'] as num).toDouble(),
        (boundsJson['northeast']['lng'] as num).toDouble(),
      ),
    );

    double totalDistance = 0;
    int totalDuration = 0;
    final steps = <AppRouteStep>[];

    for (final legJson in legs) {
      totalDistance += (legJson['distance']['value'] as num).toDouble();
      totalDuration += (legJson['duration']['value'] as num).toInt();

      for (final stepJson in (legJson['steps'] as List)) {
        steps.add(AppRouteStep(
          instruction: _stripHtml(
            stepJson['html_instructions'] as String? ?? 'Continue',
          ),
          location: LatLng(
            (stepJson['start_location']['lat'] as num).toDouble(),
            (stepJson['start_location']['lng'] as num).toDouble(),
          ),
          distanceMeters:
              (stepJson['distance']?['value'] as num?)?.toDouble() ?? 0,
        ));
      }
    }

    return AppRoute(
      polylinePoints: polylinePoints,
      bounds: bounds,
      distanceMeters: totalDistance,
      durationSeconds: totalDuration,
      steps: steps,
      origin: origin,
      destination: destination,
    );
  }

  String _stripHtml(String html) => html.replaceAll(RegExp(r'<[^>]*>'), '');
}

/// Standard Google encoded-polyline decoder. No extra package needed.
List<LatLng> decodePolyline(String encoded) {
  final points = <LatLng>[];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return points;
}