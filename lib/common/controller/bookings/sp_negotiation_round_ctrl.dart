import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_application_2/common/services/start_sp_provider_negotiation_api.dart';

class SpNegotiationRoundCtrl with ChangeNotifier {
  String? _errorMessage;
  bool _inNegotiation = false;

  /// Pending (optimistic) rounds, keyed by negotiationId so multiple
  /// negotiation threads never bleed into each other.
  final Map<int, List<NegotiationRound>> _pendingByNegotiation = {};

  String? get errorMessage => _errorMessage;
  bool get inNegotiation => _inNegotiation;

  List<NegotiationRound> pendingRoundsFor(int? negotiationId) {
    if (negotiationId == null) return const [];
    return List.unmodifiable(_pendingByNegotiation[negotiationId] ?? const []);
  }

  /// Immediately adds a "sending" bubble and returns its tempId.
  /// Call this BEFORE awaiting the network call.
  String addPendingRound({
    required int negotiationId,
    String? message,
    double? offeredPrice,
  }) {
    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final pending = NegotiationRound(
      senderType: 'provider',
      message: message,
      offeredPrice: offeredPrice,
      createdAt: DateTime.now(),
      localId: tempId,
      localStatus: RoundLocalStatus.sending,
    );

    final list = _pendingByNegotiation.putIfAbsent(negotiationId, () => []);
    list.add(pending);
    notifyListeners();
    return tempId;
  }

  void _markPending(int negotiationId, String tempId, RoundLocalStatus status) {
    final list = _pendingByNegotiation[negotiationId];
    if (list == null) return;
    final idx = list.indexWhere((r) => r.localId == tempId);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(localStatus: status);
    notifyListeners();
  }

  void removePendingRound(int negotiationId, String tempId) {
    _pendingByNegotiation[negotiationId]?.removeWhere((r) => r.localId == tempId);
    notifyListeners();
  }

  /// Performs the actual API call. UI should already be showing the
  /// pending bubble (via addPendingRound) before calling this.
  Future<bool> sendRound({
    required int negotiationId,
    required String tempId,
    String? message,
    double? offeredPrice,
  }) async {
    _errorMessage = null;
    _markPending(negotiationId, tempId, RoundLocalStatus.sending);

    try {
      final round = await StartSpProviderNegotiationApi.startProviderRound(
        negotiationId: negotiationId,
        message: message,
        offeredPrice: offeredPrice,
      );

      if (round == null) {
        _markPending(negotiationId, tempId, RoundLocalStatus.failed);
        _errorMessage = "Failed to start negotiation round.";
        notifyListeners();
        return false;
      }

      _inNegotiation = true;
      // Server confirmed it — the real round will come back through
      // refreshNegotiations(), so drop the temp placeholder.
      removePendingRound(negotiationId, tempId);
      notifyListeners();
      return true;
    } catch (e) {
      _markPending(negotiationId, tempId, RoundLocalStatus.failed);
      _errorMessage = "Error: ${e.toString()}";
      if (kDebugMode) {
        print("❌ [SpNegotiationRoundCtrl] sendRound() failed: $e");
      }
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _errorMessage = null;
    _inNegotiation = false;
    _pendingByNegotiation.clear();
    notifyListeners();
  }
}