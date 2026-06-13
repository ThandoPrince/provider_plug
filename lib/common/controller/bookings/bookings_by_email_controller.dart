import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/services/new_bookings_by_email_api.dart';
import 'package:flutter_application_2/common/services/provider_booking_socket_service.dart';

class SPBookingController with ChangeNotifier {
  final List<OrderService> _activeBookings = [];
  final ProviderBookingSocketService _socketService = ProviderBookingSocketService();

  String? _errorMessage;
  bool _isLoading = false;
  bool _isPolling = false;
  bool _isFetching = false;
  bool _isSocketMode = false;
  bool _disposed = false;

  Timer? _pollTimer;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _healthCheckTimer;

  String? _currentEmail;

  List<OrderService> get activeBookings => List.unmodifiable(_activeBookings);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  bool get isSocketMode => _isSocketMode;
  String? get currentEmail => _currentEmail;

  /// Sync polling with provider status (Guarded against status-stream redundant updates)
  Future<void> syncPollingWithStatus({
    required String email,
    required bool isOnline,
  }) async {
    if (_disposed) return;
    final normalizedEmail = email.trim().toLowerCase();

    if (isOnline) {
      if (_currentEmail == normalizedEmail && (_isSocketMode || _isPolling)) return;
      await startRealtime(normalizedEmail);
    } else {
      if (_currentEmail == null && !_isSocketMode && !_isPolling) return;
      stopRealtime(clearBookings: false);
    }
  }

  /// Entry point for real-time monitoring
  Future<void> startRealtime(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || _disposed) return;

    final isSameEmail = _currentEmail == normalizedEmail;
    if (isSameEmail && (_isPolling || _isSocketMode)) return;

    if (!isSameEmail) {
      stopRealtime(clearBookings: true);
    }

    _currentEmail = normalizedEmail;

    if (_activeBookings.isEmpty) {
      _setLoading(true);
      await fetchActiveBookings(normalizedEmail, replace: true);
    }

    await _connectSocketOrFallback(normalizedEmail);
  }

  /// Connects to socket layer with absolute fallback state isolation
  Future<void> _connectSocketOrFallback(String email) async {
    if (_disposed || _currentEmail != email) return;

    // Completely clear all running loops before mutating socket handlers
    _disposeSocketTimers();

    _socketService.onConnected = () {
      if (_disposed || _currentEmail != email) return;
      _isSocketMode = true;
      _errorMessage = null;
      _stopPollingInternal();
      _startPingTimer();
      _notify();
    };

    _socketService.onDisconnected = () {
      if (_disposed || _currentEmail != email) return;
      _isSocketMode = false;
      _startPollingFallback(email);
      _scheduleReconnect(email);
      _notify();
    };

    _socketService.onError = (error) {
      if (_disposed || _currentEmail != email) return;
      _isSocketMode = false;
      _errorMessage = error.toString();
      _startPollingFallback(email);
      _scheduleReconnect(email);
      _notify();
    };

    _socketService.onMessage = (payload) {
      if (_disposed || _currentEmail != email) return;
      final type = payload['type'];
      if (type == 'booking_invite' || type == 'booking_update') {
        fetchActiveBookings(email, replace: true);
      }
    };

    try {
      await _socketService.connect(email);
      _scheduleSocketHealthCheck(email);
    } catch (e) {
      _isSocketMode = false;
      _errorMessage = e.toString();
      _startPollingFallback(email);
      _scheduleReconnect(email);
      _notify();
    }
  }

  /// Asserts WebSocket visual state connectivity
  void _scheduleSocketHealthCheck(String email) {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer(const Duration(seconds: 4), () {
      if (_disposed || _currentEmail != email) return;
      if (_socketService.isConnected) return;
      _startPollingFallback(email);
    });
  }

  /// Fallback long-polling engine configured with protective intervals
  void _startPollingFallback(String email) {
    if (_isPolling || _disposed || _currentEmail != email) return;

    _isPolling = true;
    _pollTimer?.cancel();

    // Relaxed down from 5s to 25s to protect your backend servers from crashing
    _pollTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      if (_disposed || _currentEmail != email || _isSocketMode) {
        _stopPollingInternal();
        return;
      }
      await fetchActiveBookings(email, replace: true);
    });
  }

  void _stopPollingInternal() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_disposed || !_isSocketMode) {
        _pingTimer?.cancel();
        return;
      }
      _socketService.sendPing();
    });
  }

  /// Linear backoff reconnection mechanism tracking execution target integrity
  void _scheduleReconnect(String email) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 12), () async {
      if (_disposed || _currentEmail != email) return;
      if (_socketService.isConnected) return;
      await _connectSocketOrFallback(email);
    });
  }

  /// Tear down real-time infrastructure and clean contextual state bindings
  void stopRealtime({bool clearBookings = false}) {
    _disposeSocketTimers();
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _stopPollingInternal();
    
    _socketService.disconnect();
    _isSocketMode = false;

    if (clearBookings) {
      _activeBookings.clear();
      _currentEmail = null;
    }

    _notify();
  }

  Future<void> refresh() async {
    final email = _currentEmail;
    if (email == null || email.isEmpty) return;

    _setLoading(true);
    await fetchActiveBookings(email, replace: true);
  }

  /// Fetches system actions utilizing memory concurrency bounds
  Future<void> fetchActiveBookings(
    String email, {
    bool replace = true,
  }) async {
    if (_isFetching || _disposed || _currentEmail != email) return;

    _isFetching = true;

    try {
      final newBookings = await NewBookingsByEmailApi.fetchNewBookingByEmail(email);
      if (_disposed || _currentEmail != email) return;

      _errorMessage = null;

      if (replace) {
        _activeBookings
          ..clear()
          ..addAll(newBookings);
      } else {
        _mergeBookings(newBookings);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isFetching = false;
      _isLoading = false;
      _notify();
    }
  }

  void clearBookings() {
    _activeBookings.clear();
    _notify();
  }

  void _mergeBookings(List<OrderService> newBookings) {
    for (final booking in newBookings) {
      final exists = _activeBookings.any((existing) => existing.orderId == booking.orderId);
      if (!exists) _activeBookings.add(booking);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    _notify();
  }

  void _disposeSocketTimers() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _disposeSocketTimers();
    _healthCheckTimer?.cancel();
    _pollTimer?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}