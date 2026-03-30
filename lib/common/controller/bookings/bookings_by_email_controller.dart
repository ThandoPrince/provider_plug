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

  Timer? _pollTimer;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  String? _currentEmail;

  List<OrderService> get activeBookings => List.unmodifiable(_activeBookings);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  bool get isSocketMode => _isSocketMode;
  String? get currentEmail => _currentEmail;

  Future<void> syncPollingWithStatus({
    required String email,
    required bool isOnline,
  }) async {
    if (isOnline) {
      await startRealtime(email);
    } else {
      stopRealtime(clearBookings: false);
    }
  }

  Future<void> startRealtime(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return;

    final isSameEmail = _currentEmail == normalizedEmail;

    if (isSameEmail && (_isPolling || _isSocketMode)) {
      return;
    }

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

  Future<void> _connectSocketOrFallback(String email) async {
    _disposeSocketTimers();

    _socketService.onConnected = () {
      _isSocketMode = true;
      _stopPollingInternal();
      _startPingTimer();
      _errorMessage = null;
      notifyListeners();
    };

    _socketService.onDisconnected = () {
      _isSocketMode = false;
      notifyListeners();
      _startPollingFallback(email);
      _scheduleReconnect(email);
    };

    _socketService.onError = (error) {
      _isSocketMode = false;
      _errorMessage = error.toString();
      notifyListeners();
      _startPollingFallback(email);
      _scheduleReconnect(email);
    };

    _socketService.onMessage = (payload) {
      final type = payload['type'];
      final data = payload['data'];

      if (type == 'booking_invite' || type == 'booking_update') {
        fetchActiveBookings(email, replace: true);
      }
    };

    try {
      await _socketService.connect(email);

      // Give socket a moment; if backend is not configured, polling will still keep app working.
      _scheduleSocketHealthCheck(email);
    } catch (e) {
      _isSocketMode = false;
      _errorMessage = e.toString();
      _startPollingFallback(email);
      notifyListeners();
    }
  }

  void _scheduleSocketHealthCheck(String email) {
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentEmail != email) return;
      if (_socketService.isConnected) return;

      _startPollingFallback(email);
      notifyListeners();
    });
  }

  void _startPollingFallback(String email) {
    if (_isPolling) return;

    _isPolling = true;
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_currentEmail == null || _currentEmail != email) return;
      await fetchActiveBookings(email, replace: true);
    });

    notifyListeners();
  }

  void _stopPollingInternal() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _socketService.sendPing();
    });
  }

  void _scheduleReconnect(String email) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 8), () async {
      if (_currentEmail != email) return;
      if (_socketService.isConnected) return;
      await _connectSocketOrFallback(email);
    });
  }

  void stopRealtime({bool clearBookings = false}) {
    _disposeSocketTimers();
    _socketService.disconnect();
    _stopPollingInternal();
    _isSocketMode = false;

    if (clearBookings) {
      _activeBookings.clear();
      _currentEmail = null;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    final email = _currentEmail;
    if (email == null || email.isEmpty) return;

    _setLoading(true);
    await fetchActiveBookings(email, replace: true);
  }

  Future<void> fetchActiveBookings(
    String email, {
    bool replace = true,
  }) async {
    if (_isFetching) return;

    _isFetching = true;

    try {
      final newBookings =
          await NewBookingsByEmailApi.fetchNewBookingByEmail(email);

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
      notifyListeners();
    }
  }

  void clearBookings() {
    _activeBookings.clear();
    notifyListeners();
  }

  void _mergeBookings(List<OrderService> newBookings) {
    for (final booking in newBookings) {
      final exists = _activeBookings.any(
        (existing) => existing.orderId == booking.orderId,
      );

      if (!exists) {
        _activeBookings.add(booking);
      }
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _disposeSocketTimers() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  @override
  void dispose() {
    _disposeSocketTimers();
    _socketService.dispose();
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }
}