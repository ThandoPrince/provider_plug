import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_application_2/common/services/get_sp_negotiation_api.dart';

class SpNegotiationsByIdEmailCtrl extends ChangeNotifier {
  /// Cached negotiations per (orderId|email)
  final Map<String, List<NegotiationModel>> _negotiationsMap = {};

  /// Loading state per key
  final Map<String, bool> _loadingMap = {};

  /// Error state per key
  final Map<String, String?> _errorMap = {};

  // ──────────────────────────
  // Helpers
  // ──────────────────────────

  String _key(int orderId) =>
      '$orderId';

  List<NegotiationModel> negotiations(String key) =>
      _negotiationsMap[key] ?? [];

  bool isLoading(String key) => _loadingMap[key] ?? false;

  String? error(String key) => _errorMap[key];

  // ──────────────────────────
  // Public API
  // ──────────────────────────

  /// Initial load (cached)
  Future<void> loadNegotiations({
  required int orderId,
  bool forceRefresh = false,
}) async {
  debugPrint("loadNegotiations controller = $hashCode");
  final key = _key(orderId);

  debugPrint("loadNegotiations($orderId)");

  if (isLoading(key)) {
    debugPrint("Already loading");
    return;
  }

  if (!forceRefresh && _negotiationsMap.containsKey(key)) {
    debugPrint("Already cached");
    return;
  }

  _setLoading(key, true);

  try {
    final fetched = await GetSpNegotiationApi.fetchNegotiations(
      orderId: orderId,
    );

    debugPrint("Fetched ${fetched.length} negotiations");

    _negotiationsMap[key] = fetched;

    debugPrint("Current keys: ${_negotiationsMap.keys}");

    for (final n in fetched) {
      debugPrint("Negotiation id = ${n.negotiationId}");
    }
  } catch (e) {
    debugPrint("LOAD ERROR: $e");
    _negotiationsMap[key] = [];
  } finally {
    _setLoading(key, false);
  }
}


void handleSocketEvent(Map<String, dynamic> data) {
  debugPrint("handleSocketEvent controller = $hashCode");
  debugPrint("handleSocketEvent: $data");

  switch(data["action"]) {

    case "new_round":

      final round = NegotiationRound.fromJson(
        data["round"],
      );
       debugPrint("Adding round ${round.id}");

      addRound(
        data["negotiation_id"],
        round,
      );

      break;
  }
}

void addRound(
  int negotiationId,
  NegotiationRound round,
) {
  debugPrint("_negotiationsMap keys: ${_negotiationsMap.keys}");
  debugPrint("Looking for negotiation $negotiationId");

  for (final entry in _negotiationsMap.entries) {
    debugPrint("KEY = ${entry.key}");
    debugPrint("Order key: ${entry.key}");



    for (final negotiation in entry.value) {
      
      debugPrint(
          "Cached negotiation = ${negotiation.negotiationId}");
          debugPrint(
        "Negotiation cached: ${negotiation.negotiationId}",
      );

      if (negotiation.negotiationId == negotiationId) {
        debugPrint("FOUND!");

        final rounds = negotiation.rounds;

        if (rounds == null) {
          debugPrint("Rounds is null");
          return;
        }

        final exists = rounds.any((r) => r.id == round.id);

        debugPrint("Exists = $exists");

        if (!exists) {
          rounds.add(round);
          debugPrint("Added round");
          notifyListeners();
        }

        return;
      }
    }
  }

  debugPrint("Negotiation NOT FOUND");
}


  /// 🔥 Force refresh (used after Send / Accept)
  Future<void> refreshNegotiations({
    required int orderId,
    
  }) async {
    final key = _key(orderId);

    // Keep old data while refreshing (important for AnimatedList)
    _errorMap[key] = null;
    notifyListeners();

    await loadNegotiations(
      orderId: orderId,
     
      forceRefresh: true,
    );
  }

  /// Clear a specific negotiation cache
  void clearNegotiation({
    required int orderId,
    required String email,
  }) {
    final key = _key(orderId);
    _negotiationsMap.remove(key);
    _loadingMap.remove(key);
    _errorMap.remove(key);
    notifyListeners();
  }

  /// Clear everything (logout / app reset)
  void clearAll() {
    _negotiationsMap.clear();
    _loadingMap.clear();
    _errorMap.clear();
    notifyListeners();
  }

  // ──────────────────────────
  // Internal helpers
  // ──────────────────────────

  void _setLoading(String key, bool value) {
    _loadingMap[key] = value;
    notifyListeners();
  }
}
