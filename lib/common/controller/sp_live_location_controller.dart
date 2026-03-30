import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/client_models/sp_live_location_post_model.dart';
import 'package:flutter_application_2/common/services/sp_live_location_post_api.dart';
import 'package:geolocator/geolocator.dart';

class SpLiveLocationPostController extends ChangeNotifier {
  Timer? _timer;

  bool _isTracking = false;
  bool _isSending = false;
  bool _disposed = false;

  String? _currentEmail;

  bool get isTracking => _isTracking;
  bool get isSending => _isSending;
  String? get currentEmail => _currentEmail;

  /// Sync tracking with provider status (same pattern as bookings)
  Future<void> syncTrackingWithStatus({
    required String email,
    required bool isOnline,
  }) async {
    if (isOnline) {
      await startTracking(email: email);
    } else {
      stopTracking();
    }
  }

  /// Start tracking
  Future<void> startTracking({
    required String email,
    int intervalSeconds = 20,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || _disposed) return;

    final isSameEmail = _currentEmail == normalizedEmail;

    // Already tracking same email
    if (_isTracking && isSameEmail) return;

    // If email changed → reset
    if (_isTracking && !isSameEmail) {
      stopTracking();
    }

    _currentEmail = normalizedEmail;
    _isTracking = true;
    _notify();

    // Send immediately (important UX improvement)
    await _sendLocation(normalizedEmail);

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      if (!_isTracking || _disposed || _currentEmail == null) return;

      await _sendLocation(_currentEmail!);
    });
  }

  /// Stop tracking
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _currentEmail = null;
    _notify();
  }

  /// Send location safely
  Future<void> _sendLocation(String email) async {
    if (_disposed || _isSending) return;

    _isSending = true;
    _notify();

    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final model = SpLiveLocationPostModel(
        email: email,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final success = await SpLiveLocationService.sendLiveLocation(model);

      if (!success) {
        debugPrint("❌ Failed to send location");
      }
    } catch (e) {
      debugPrint("❌ Location error: $e");
    } finally {
      if (!_disposed) {
        _isSending = false;
        _notify();
      }
    }
  }

  /// Handle permission safely
  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("⚠️ Location services disabled");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("⚠️ Location permission denied");
      return false;
    }

    return true;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposed = true;
    super.dispose();
  }
}