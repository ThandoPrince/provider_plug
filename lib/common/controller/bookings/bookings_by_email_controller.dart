import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/services/new_bookings_by_email_api.dart';
import 'package:flutter_application_2/common/services/provider_booking_socket_service.dart';
import 'package:flutter/scheduler.dart';
class SPBookingController with ChangeNotifier {
  final List<OrderService> _activeBookings = [];
  final ProviderBookingSocketService _socketService;
   SpNegotiationsByIdEmailCtrl negotiationsCtrl;

SPBookingController(this._socketService, this.negotiationsCtrl,);

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
  int? _providerId;

int? get currentProviderId => _providerId;



  List<OrderService> get activeBookings => List.unmodifiable(_activeBookings);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  bool get isSocketMode => _isSocketMode;
  

  /// Sync polling with provider status (Guarded against status-stream redundant updates)
  Future<void> syncPollingWithStatus({
  required bool isOnline,
}) async {
  if (_disposed) return;

  final providerID = AuthSessionController.instance.id;

  if (providerID == null) return;

  if (isOnline) {
    if (_providerId == providerID &&
        (_isSocketMode || _isPolling)) {
      return;
    }

    await startRealtime(providerID);
  } else {
    if (_providerId == null &&
        !_isSocketMode &&
        !_isPolling) {
      return;
    }

    stopRealtime(clearBookings: false);
  }
}

 Future<void> startRealtime(int providerId) async {
  if (_disposed) return;

  final sameProvider = _providerId == providerId;

  if (sameProvider &&
      (_isSocketMode || _isPolling)) {
    return;
  }

  if (!sameProvider) {
    stopRealtime(clearBookings: true);
  }

  _providerId = providerId;

  if (_activeBookings.isEmpty) {
    _setLoading(true);
    await fetchActiveBookings(providerId, replace: true);
  }

  await _connectSocketOrFallback(providerId);


}

void _safeNotify() {
  if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle ||
      SchedulerBinding.instance.schedulerPhase == SchedulerPhase.postFrameCallbacks) {
    notifyListeners();
  } else {
    // We're mid-build/layout/paint — defer to right after this frame.
    SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
}

  /// Connects to socket layer with absolute fallback state isolation
  Future<void> _connectSocketOrFallback(int providerId) async {
    
  if (_disposed || _providerId != providerId) {
    return;
  }

  _disposeSocketTimers();

  _socketService.onConnected = () {
    if (_disposed || _providerId != providerId) {
      return;
    }

    _isSocketMode = true;
    _errorMessage = null;

    _stopPollingInternal();
    _startPingTimer();

    _notify();
  };

  _socketService.onDisconnected = () {
    if (_disposed || _providerId != providerId) {
      return;
    }

    _isSocketMode = false;

    _startPollingFallback(providerId);
    _scheduleReconnect(providerId);

    _notify();
  };

  

  _socketService.onError = (error) {
    if (_disposed || _providerId != providerId) {
      return;
    }

    _isSocketMode = false;
    _errorMessage = error.toString();

    _startPollingFallback(providerId);
    _scheduleReconnect(providerId);

    _notify();
  };

  _socketService.onMessage = (payload) {
  debugPrint("SOCKET EVENT: ${payload["type"]}");

  if (_disposed || _providerId != providerId) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_disposed || _providerId != providerId) return;
debugPrint("Payload type = '${payload["type"]}'");
debugPrint("Current provider = $_providerId");
debugPrint("Incoming provider = $providerId");
debugPrint("Disposed = $_disposed");

    switch (payload["type"]) {
  case "booking_update":
  
  case "booking_invite":
  debugPrint("BOOKING INVITE MATCHED");
   
    fetchActiveBookings(providerId, replace: true);
    debugPrint("BOOKING INVITE DONE");
    break;
      case "negotiation_update":
  debugPrint("NEGOTIATION UPDATE");

  debugPrint("Before handleSocketEvent");
  negotiationsCtrl.handleSocketEvent(payload["data"]);
  debugPrint("After handleSocketEvent");

  break;
    }
  });
};

  try {
    await _socketService.connect();
    _scheduleSocketHealthCheck(providerId);
  } catch (e) {
    _isSocketMode = false;
    _errorMessage = e.toString();

    _startPollingFallback(providerId);
    _scheduleReconnect(providerId);

    _notify();
  }
}

  /// Asserts WebSocket visual state connectivity
  void _scheduleSocketHealthCheck(int providerId) {
  _healthCheckTimer?.cancel();

  _healthCheckTimer = Timer(
    const Duration(seconds: 4),
    () {
      if (_disposed || _providerId != providerId) {
        return;
      }

      if (_socketService.isConnected) {
        return;
      }

      _startPollingFallback(providerId);
    },
  );
}

  /// Fallback long-polling engine configured with protective intervals
  void _startPollingFallback(int providerId) {
  if (_isPolling ||
      _disposed ||
      _providerId != providerId) {
    return;
  }

  _isPolling = true;

  _pollTimer?.cancel();

  _pollTimer = Timer.periodic(
    const Duration(seconds: 25),
    (_) async {
      if (_disposed ||
          _providerId != providerId ||
          _isSocketMode) {
        _stopPollingInternal();
        return;
      }

      await fetchActiveBookings(
        providerId,
        replace: true,
      );
    },
  );
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
  void _scheduleReconnect(int providerId) {
  _reconnectTimer?.cancel();

  _reconnectTimer = Timer(
    const Duration(seconds: 12),
    () async {
      if (_disposed ||
          _providerId != providerId) {
        return;
      }

      if (_socketService.isConnected) {
        return;
      }

      await _connectSocketOrFallback(providerId);
    },
  );
}

  /// Tear down real-time infrastructure and clean contextual state bindings
  void stopRealtime({
  bool clearBookings = false,
}) {
  _disposeSocketTimers();

  _healthCheckTimer?.cancel();
  _healthCheckTimer = null;

  _stopPollingInternal();

  _socketService.disconnect();

  _isSocketMode = false;

  if (clearBookings) {
    _activeBookings.clear();
    _providerId = null;
  }

  _notify();
}

  Future<void> refresh() async {
  final providerId = _providerId;

  if (providerId == null) {
    return;
  }

  _setLoading(true);

  await fetchActiveBookings(
    providerId,
    replace: true,
  );
}

  /// Fetches system actions utilizing memory concurrency bounds
  Future<void> fetchActiveBookings(
  int providerId, {
  bool replace = true,
}) async {
  if (_isFetching ||
      _disposed ||
      _providerId != providerId) {
    return;
  }

  _isFetching = true;

  try {
    final bookings =
        await NewBookingsByEmailApi.fetchNewBookingByEmail(
      
    );

    if (_disposed || _providerId != providerId) {
      return;
    }

    _errorMessage = null;

    if (replace) {
      _activeBookings
        ..clear()
        ..addAll(bookings);
    } else {
      _mergeBookings(bookings);
    }
  } catch (e) {
    _errorMessage =
        e.toString().replaceAll("Exception: ", "");
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