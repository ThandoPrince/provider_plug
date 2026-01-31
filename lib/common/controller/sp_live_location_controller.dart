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

  bool get isTracking => _isTracking;
  bool get isSending => _isSending;

  /// Start live location tracking
  void startTracking({required String email, int intervalSeconds = 20}) {
    if (_isTracking || _disposed) return;

    _isTracking = true;
    _safeNotifyListeners();

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      if (_disposed) return; // Stop if disposed
      await _sendLocation(email);
    });
  }

  /// Stop tracking safely
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _safeNotifyListeners();
  }

  /// Send current GPS location to server
  Future<void> _sendLocation(String email) async {
    if (_disposed) return;

    _isSending = true;
    _safeNotifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final model = SpLiveLocationPostModel(
        email: email,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final success = await SpLiveLocationService.sendLiveLocation(model);
      if (!success) debugPrint("❌ Failed to send location to server");
    } catch (e) {
      debugPrint("❌ Location send error: $e");
    } finally {
      if (!_disposed) {
        _isSending = false;
        _safeNotifyListeners();
      }
    }
  }

  /// Safe notifyListeners that avoids disposed crashes and tree-locked errors
  void _safeNotifyListeners() {
    if (!_disposed) {
      // Post-frame callback ensures no setState while tree is locked
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _disposed = true; // Mark disposed first
    super.dispose();
  }
}
