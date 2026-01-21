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

  void startTracking({required String email, int intervalSeconds = 20}) {
    if (_isTracking || _disposed) return;

    _isTracking = true;
    _safeNotifyListeners();

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      if (_disposed) return; // Safety: stop sending if disposed
      await _sendLocation(email);
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;

    if (!_disposed) _safeNotifyListeners(); // Only notify if not disposed
  }

  Future<void> _sendLocation(String email) async {
    try {
      if (_disposed) return;

      _isSending = true;
      _safeNotifyListeners();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final model = SpLiveLocationPostModel(
        email: email,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final success = await SpLiveLocationService.sendLiveLocation(model);
      if (!success) debugPrint("Failed to send location to server");
    } catch (e) {
      debugPrint("Location send error: $e");
    } finally {
      if (!_disposed) {
        _isSending = false;
        _safeNotifyListeners();
      }
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      try {
        notifyListeners();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _disposed = true; // Set disposed last
    super.dispose();
  }
}
