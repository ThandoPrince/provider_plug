import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/services/new_bookings_by_email_api.dart';
import 'package:flutter_application_2/common/services/provider_booking_socket_service.dart';
import 'package:flutter/scheduler.dart';

/// High-level connection state for the UI to react to, instead of
/// branching directly on a raw error string.
enum BookingConnectionStatus { live, reconnecting, offline, noNetwork }

class SPBookingController with ChangeNotifier, WidgetsBindingObserver {
  final List<OrderService> _activeBookings = [];
  final ProviderBookingSocketService _socketService;
  SpNegotiationsByIdEmailCtrl negotiationsCtrl;
  bool _hasConnectedOnce = false;

  bool get hasConnectedOnce => _hasConnectedOnce;

  SPBookingController(this._socketService, this.negotiationsCtrl) {
    WidgetsBinding.instance.addObserver(this);
  }

  String? _errorMessage;
  bool _isLoading = false;
  bool _isPolling = false;
  bool _isFetching = false;
  bool _isSocketMode = false;
  bool _disposed = false;

  // True when the last failure was classified as "no network path to the
  // server" (no connectivity, DNS failure, host unreachable). While this is
  // true, we deliberately stop retrying instead of backing off — see
  // _handleConnectionFailure.
  bool _networkUnavailable = false;

  // --- App-lifecycle / resume handling -------------------------------
  // When the screen is off or the app is backgrounded, our Timers
  // (_pingTimer, _healthCheckTimer, _reconnectTimer) are effectively
  // frozen by the OS, and the underlying socket can die silently. Without
  // this, the stale health-check timer fires the instant the app resumes,
  // flips into "reconnecting", and then the socket reconnects a moment
  // later — producing a visible flash of the reconnecting banner. We
  // instead check proactively on resume and give it a short grace window
  // before letting the UI show anything.
  DateTime? _backgroundedAt;
  bool _isResumingCheck = false;

  Timer? _pollTimer;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _healthCheckTimer;
  Timer? _resumeCheckTimer;
  int? _providerId;

  int _reconnectAttempts = 0;
  final Random _random = Random();

  int? get currentProviderId => _providerId;

  List<OrderService> get activeBookings => List.unmodifiable(_activeBookings);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  bool get isSocketMode => _isSocketMode;
  bool get isNetworkUnavailable => _networkUnavailable;

  BookingConnectionStatus get connectionStatus {
    // Suppress status changes while we're silently verifying the socket
    // right after a resume — this is what prevents the flash. If the
    // socket really is dead, this window is short (see
    // _verifySocketAfterResume) and the UI will still show reconnecting
    // once the grace period elapses.
    if (_isResumingCheck) return BookingConnectionStatus.live;
    if (_isSocketMode) return BookingConnectionStatus.live;
    if (_networkUnavailable) return BookingConnectionStatus.noNetwork;
    if (_isPolling || _reconnectTimer != null) {
      return BookingConnectionStatus.reconnecting;
    }
    return BookingConnectionStatus.offline;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Only record the first transition into background — inactive
        // fires briefly even for things like a system dialog, so don't
        // keep overwriting the timestamp.
        _backgroundedAt ??= DateTime.now();
        break;
      case AppLifecycleState.resumed:
        _handleResume();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void _handleResume() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;

    if (_disposed || _providerId == null) return;

    // A brief glance away (app switcher, notification shade) isn't worth
    // disturbing anything — the socket is almost certainly still fine.
    if (backgroundedAt == null ||
        DateTime.now().difference(backgroundedAt) < const Duration(seconds: 2)) {
      return;
    }

    debugPrint("📱 App resumed after background — validating booking connection");

    // Always refresh via REST immediately regardless of socket state, so
    // the list is correct even if the socket is still silently dead and
    // hasn't told us yet.
    fetchActiveBookings(_providerId!, replace: true);

    _verifySocketAfterResume();
  }

  /// Gives the socket a short window to reveal itself as dead (via
  /// onError/onDone) before we let the UI flip to "reconnecting". Most of
  /// the time the health check below finds it already reconnected or
  /// still connected, and nothing is ever shown to the user.
  void _verifySocketAfterResume() {
    final providerId = _providerId;
    if (providerId == null) return;

    _isResumingCheck = true;
    _resumeCheckTimer?.cancel();

    _resumeCheckTimer = Timer(const Duration(milliseconds: 800), () {
      if (_disposed || _providerId != providerId) return;

      _isResumingCheck = false;

      if (!_socketService.isConnected) {
        _isSocketMode = false;
        _startPollingFallback(providerId);
        _scheduleReconnect(providerId);
      }

      _notify();
    });
  }

  Future<void> syncPollingWithStatus({required bool isOnline}) async {
    if (_disposed) return;

    final providerID = AuthSessionController.instance.id;
    if (providerID == null) return;

    if (isOnline) {
      if (_providerId == providerID && (_isSocketMode || _isPolling)) return;
      await startRealtime(providerID);
    } else {
      if (_providerId == null && !_isSocketMode && !_isPolling) return;
      stopRealtime(clearBookings: false);
    }
  }

  Future<void> startRealtime(int providerId) async {
    if (_disposed) return;

    final sameProvider = _providerId == providerId;

    if (sameProvider && (_isSocketMode || _isPolling)) return;

    if (!sameProvider) {
      stopRealtime(clearBookings: true);
    }

    _providerId = providerId;
    _reconnectAttempts = 0;
    // Any explicit (re)start is a fresh attempt — don't stay stuck showing
    // "no network" from a previous session once something has asked us to
    // try again.
    _networkUnavailable = false;

    if (_activeBookings.isEmpty) {
      _setLoading(true);
      await fetchActiveBookings(providerId, replace: true);
    }

    await _connectSocketOrFallback(providerId);
  }

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle ||
        SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  Future<void> _connectSocketOrFallback(int providerId) async {
    if (_disposed || _providerId != providerId) return;

    _disposeSocketTimers();

    _socketService.onConnected = () {
      if (_disposed || _providerId != providerId) return;

      _isSocketMode = true;
      _errorMessage = null;
      _reconnectAttempts = 0;
      _hasConnectedOnce = true;
      _networkUnavailable = false;
      _isResumingCheck = false;
      _resumeCheckTimer?.cancel();
      _resumeCheckTimer = null;

      _reconnectTimer?.cancel();
      _reconnectTimer = null;

      _stopPollingInternal();
      _startPingTimer();
      _notify();
    };

    _socketService.onDisconnected = () {
      if (_disposed || _providerId != providerId) return;

      // A clean stream close (onDone) carries no error object, so there's
      // nothing to classify here — treat it as before and let the normal
      // backoff try again.
      _isSocketMode = false;
      _startPollingFallback(providerId);
      _scheduleReconnect(providerId);
      _notify();
    };

    _socketService.onError = (error) {
      if (_disposed || _providerId != providerId) return;

      _isSocketMode = false;
      _handleConnectionFailure(error, providerId);
      _notify();
    };

    _socketService.onMessage = (payload) {
      debugPrint("SOCKET EVENT: ${payload["type"]}");
      if (_disposed || _providerId != providerId) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed || _providerId != providerId) return;

        switch (payload["type"]) {
          case "booking_update":
          case "booking_invite":
            fetchActiveBookings(providerId, replace: true);
            break;
          case "negotiation_update":
            negotiationsCtrl.handleSocketEvent(payload["data"]);
            break;
        }
      });
    };

    try {
      // After a couple of plain-connect failures in a row, assume the
      // token has expired and refresh it before retrying.
      if (_reconnectAttempts > 0 && _reconnectAttempts % 2 == 0) {
        await _socketService.reconnectWithTokenRefresh();
      } else {
        await _socketService.connect();
      }

      _scheduleSocketHealthCheck(providerId);
    } catch (e) {
      _isSocketMode = false;
      _handleConnectionFailure(e, providerId);
    }
  }

  /// Decides how to react to a connection failure. Network-unavailable
  /// failures (no connectivity, DNS failure, host unreachable) stop here —
  /// retrying against a network that isn't there just burns battery and
  /// spams the same error. Anything else keeps the existing polling +
  /// backoff-reconnect behavior.
  void _handleConnectionFailure(Object error, int providerId) {
    if (error is NetworkUnavailableException) {
      debugPrint("📴 Network unavailable — disconnecting instead of retrying: $error");
      _networkUnavailable = true;
      _errorMessage = "No internet connection";
      stopRealtime(clearBookings: false);
      return;
    }

    _networkUnavailable = false;
    _errorMessage = error.toString();
    _startPollingFallback(providerId);
    _scheduleReconnect(providerId);
  }

  void _scheduleSocketHealthCheck(int providerId) {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer(const Duration(seconds: 4), () {
      if (_disposed || _providerId != providerId) return;
      if (_socketService.isConnected) return;

      _startPollingFallback(providerId);
    });
  }

  void _startPollingFallback(int providerId) {
    if (_isPolling || _disposed || _providerId != providerId) return;

    _isPolling = true;
    _pollTimer?.cancel();

    _pollTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
      if (_disposed || _providerId != providerId || _isSocketMode) {
        _stopPollingInternal();
        return;
      }

      await fetchActiveBookings(providerId, replace: true);
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

  /// Exponential backoff with jitter (3s, 6s, 12s, 24s, 48s, capped at 60s)
  /// instead of a fixed interval, so a flappy connection doesn't hammer
  /// the server, and resets to 3s the moment a connection succeeds.
  void _scheduleReconnect(int providerId) {
    _reconnectTimer?.cancel();

    final delay = _nextReconnectDelay();

    _reconnectTimer = Timer(delay, () async {
      if (_disposed || _providerId != providerId) return;
      if (_socketService.isConnected) return;

      _reconnectAttempts++;
      await _connectSocketOrFallback(providerId);
    });

    // Reflect "reconnecting" state immediately so the UI banner can show
    // without waiting for the timer to fire.
    _notify();
  }

  Duration _nextReconnectDelay() {
    final capped = _reconnectAttempts.clamp(0, 5);
    final baseSeconds = 3 * (1 << capped);
    final jitterSeconds = _random.nextInt(3);
    final totalSeconds = (baseSeconds + jitterSeconds).clamp(3, 60);
    return Duration(seconds: totalSeconds);
  }

  void stopRealtime({bool clearBookings = false}) {
    _disposeSocketTimers();

    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;

    _resumeCheckTimer?.cancel();
    _resumeCheckTimer = null;
    _isResumingCheck = false;

    // Fixed: this was previously left uncancelled despite the old comment
    // claiming it happened here — a pending reconnect attempt would fire
    // later and undo the stop.
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _stopPollingInternal();
    _socketService.disconnect();
    _isSocketMode = false;
    _reconnectAttempts = 0;

    if (clearBookings) {
      _activeBookings.clear();
      _providerId = null;
    }

    _notify();
  }

  Future<void> refresh() async {
    final providerId = _providerId;
    if (providerId == null) return;

    _setLoading(true);
    await fetchActiveBookings(providerId, replace: true);
  }

  Future<void> fetchActiveBookings(
    int providerId, {
    bool replace = true,
  }) async {
    if (_isFetching || _disposed || _providerId != providerId) return;

    _isFetching = true;

    try {
      final bookings = await NewBookingsByEmailApi.fetchNewBookingByEmail();

      if (_disposed || _providerId != providerId) return;

      _errorMessage = null;

      if (replace) {
        _activeBookings
          ..clear()
          ..addAll(bookings);
      } else {
        _mergeBookings(bookings);
      }
    } catch (e) {
      // Deliberately does NOT clear _activeBookings — a failed refresh
      // should leave the last known-good list on screen, with the error
      // surfaced separately by the UI.
      _errorMessage = e.toString().replaceAll("Exception: ", "");
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
      final exists =
          _activeBookings.any((existing) => existing.orderId == booking.orderId);
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
    // Reconnect timer is cancelled explicitly in stopRealtime() and
    // onConnected, not here — a fresh reconnect attempt calling this
    // would otherwise cancel its own in-flight timer.
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    _resumeCheckTimer?.cancel();
    _disposeSocketTimers();
    _healthCheckTimer?.cancel();
    _pollTimer?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}