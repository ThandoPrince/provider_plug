
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/services/provider_booking_socket_service.dart';
import 'package:geolocator/geolocator.dart';

class SpLiveLocationPostController extends ChangeNotifier {
  final ProviderBookingSocketService _socketService;

  SpLiveLocationPostController(this._socketService) {
    debugPrint("📍 SpLiveLocationPostController initialized");

    _socketService.onConnected = () {
      debugPrint("🟢 WebSocket connected");

      if (_isTracking && _currentProviderId != null) {
        debugPrint(
          "📡 Restarting location upload after reconnect "
          "(provider=$_currentProviderId)",
        );

        _sendLocation(_currentProviderId!);
      }
    };
  }

  StreamSubscription<Position>? _positionSubscription;

  Position? _latestPosition;

  bool _isTracking = false;
  bool _isSending = false;
  bool _disposed = false;

  int? _currentProviderId;

  bool get isTracking => _isTracking;
  bool get isSending => _isSending;
  int? get currentProviderId => _currentProviderId;

  /// Sync tracking with provider online/offline status.
  Future<void> syncTrackingWithStatus({
    required int providerId,
    required bool isOnline,
  }) async {
    if (_disposed) return;

    if (isOnline) {
      if (_isTracking && _currentProviderId == providerId) {
        return;
      }

      await startTracking(
        providerId: providerId,
      );
    } else {
      if (!_isTracking) return;

      await stopTracking();
    }
  }

  /// Start provider live-location tracking.
  Future<void> startTracking({
    required int providerId,
  }) async {
    if (_disposed) return;

    if (_isTracking && _currentProviderId == providerId) {
      return;
    }

    await stopTracking(notify: false);

    final hasPermission = await _ensurePermission();

    if (!hasPermission || _disposed) {
      return;
    }

    _currentProviderId = providerId;
    _isTracking = true;

    _notify();

    // Send initial location immediately.
    await _sendLocation(providerId);

    // Logout/status change may have happened while
    // the initial location was being retrieved.
    if (!_isTracking || _disposed) {
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen(
      (position) async {
        if (!_isTracking || _disposed) {
          return;
        }

        _latestPosition = position;

        debugPrint(
          "📍 Position changed: "
          "${position.latitude}, ${position.longitude}",
        );

        await _sendLocation(providerId);
      },
      onError: (error) {
        debugPrint(
          "❌ Position stream error: $error",
        );
      },
    );
  }

  /// Stop provider live-location tracking.
  Future<void> stopTracking({
    bool notify = true,
  }) async {
    debugPrint("📍 Stopping live location tracking");

    // Set this BEFORE awaiting cancellation.
    // This immediately prevents new location sends.
    _isTracking = false;

    _currentProviderId = null;
    _latestPosition = null;

    final subscription = _positionSubscription;

    _positionSubscription = null;

    if (subscription != null) {
      await subscription.cancel();
    }

    debugPrint("📍 Live location tracking stopped");

    if (notify) {
      _notify();
    }
  }

  /// Send live location through the provider booking socket.
  Future<void> _sendLocation(int providerId) async {
    debugPrint("📍 _sendLocation ENTER");

    if (_disposed ||
        !_isTracking ||
        _currentProviderId != providerId ||
        _isSending) {
      debugPrint(
        "❌ Returning "
        "disposed=$_disposed "
        "tracking=$_isTracking "
        "currentProvider=$_currentProviderId "
        "requestedProvider=$providerId "
        "sending=$_isSending",
      );

      return;
    }

    _isSending = true;

    _notify();

    try {
      final hasPermission = await _ensurePermission();

      if (!hasPermission ||
          _disposed ||
          !_isTracking ||
          _currentProviderId != providerId) {
        debugPrint(
          "❌ Location send cancelled after permission check",
        );

        return;
      }

      Position? position = _latestPosition;

      position ??= await Geolocator.getLastKnownPosition();

      // Check again because this await could complete after logout.
      if (_disposed ||
          !_isTracking ||
          _currentProviderId != providerId) {
        debugPrint(
          "❌ Location send cancelled after position lookup",
        );

        return;
      }

      if (position == null) {
        debugPrint(
          "❌ No location available yet.",
        );

        return;
      }

      debugPrint(
        "📍 Sending "
        "${position.latitude}, "
        "${position.longitude}",
      );

      // Final guard before touching the socket.
      if (_disposed ||
          !_isTracking ||
          _currentProviderId != providerId) {
        debugPrint(
          "❌ Location send cancelled before socket send",
        );

        return;
      }

      await _socketService.sendLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      debugPrint(
        "✅ WebSocket location send finished",
      );
    } catch (e, stack) {
      debugPrint(
        "❌ _sendLocation exception",
      );
      debugPrint("$e");
      debugPrint("$stack");
    } finally {
      _isSending = false;
      _notify();
    }
  }

  /// Check location permissions.
  Future<bool> _ensurePermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _isTracking = false;
    _currentProviderId = null;
    _latestPosition = null;

    _positionSubscription?.cancel();
    _positionSubscription = null;

    super.dispose();
  }
}

