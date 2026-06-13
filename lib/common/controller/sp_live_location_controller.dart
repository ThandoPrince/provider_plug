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

  /// Sync tracking with provider status (Guarded against status-stream redundancy)
  Future<void> syncTrackingWithStatus({
    required String email,
    required bool isOnline,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    
    if (isOnline) {
      // Avoid re-triggering tracking if nothing has changed
      if (_isTracking && _currentEmail == normalizedEmail) return;
      await startTracking(email: normalizedEmail);
    } else {
      if (!_isTracking) return;
      stopTracking();
    }
  }

  /// Start tracking with absolute guard setups
  Future<void> startTracking({
    required String email,
    int intervalSeconds = 30, // Relaxed telemetry window slightly for resource relief
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || _disposed) return;

    // Hard blocker: Ensure previous timer instances are completely dropped *before* any async gaps
    _timer?.cancel();
    _timer = null;

    final isSameEmail = _currentEmail == normalizedEmail;
    if (_isTracking && isSameEmail) {
      // Re-initialize periodic loop if it was dropped but state matches
      _setupTimer(normalizedEmail, intervalSeconds);
      return;
    }

    if (_isTracking && !isSameEmail) {
      stopTracking();
    }

    _currentEmail = normalizedEmail;
    _isTracking = true;
    _notify();

    // Start periodic background loop prior to processing long execution steps
    _setupTimer(normalizedEmail, intervalSeconds);

    // Isolated tracking trigger
    await _sendLocation(normalizedEmail);
  }

  /// Extracted timer setup logic to safely handle context bounds
  void _setupTimer(String email, int intervalSeconds) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (!_isTracking || _disposed || _currentEmail != email) {
        _timer?.cancel();
        return;
      }
      // Fire-and-forget inside standard tick so it doesn't back up execution blocks
      _sendLocation(email);
    });
  }

  /// Stop tracking and purge system loop allocations
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _currentEmail = null;
    _notify();
  }

  /// Send location safely with concurrency protection and relaxed geolocator queries
  Future<void> _sendLocation(String email) async {
    if (_disposed || _isSending) return;

    _isSending = true;
    _notify();

    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission || _disposed || !_isTracking) return;

      // OPTIMIZATION: Swapped from getCurrentPosition (heavy hardware query) to getLastKnownPosition
      // Falls back to standard query only if cache is completely empty.
      Position? position = await Geolocator.getLastKnownPosition();
      
      position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low, // Balanced accuracy uses significantly less battery & CPU
          timeLimit: const Duration(seconds: 5),
        );

      // Final dynamic sanity check after operational latency gap
      if (_disposed || !_isTracking || _currentEmail != email) return;

      final model = SpLiveLocationPostModel(
        email: email,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final success = await SpLiveLocationService.sendLiveLocation(model);

      if (!success) {
        debugPrint("❌ Failed to send location telemetry packet");
      }
    } catch (e) {
      debugPrint("❌ Location tracking exception caught: $e");
    } finally {
      if (!_disposed) {
        _isSending = false;
        _notify();
      }
    }
  }

  /// Handle permission constraints gracefully
  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied && 
           permission != LocationPermission.deniedForever;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _disposed = true;
    super.dispose();
  }
}