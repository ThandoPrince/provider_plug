import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_application_2/common/services/view_negotiation_rounds_by_nego_id_api.dart';

class NegotiationRoundsCtrl extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<NegotiationRound> _rounds = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ✅ Getter for rounds
  List<NegotiationRound> get rounds => List.unmodifiable(_rounds);

  Future<void> fetchRounds(int negotiationId, {bool forceRefresh = false}) async {
    if (_rounds.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<dynamic> roundsData =
          await ViewNegotiationRoundsByNegoIdApi.fetchRoundsByNegotiationId(negotiationId);

          if (kDebugMode) {
            print(roundsData);
          }

      // ✅ Map dynamic list to typed NegotiationRound list
      _rounds = roundsData.map((json) => NegotiationRound.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      _rounds = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addRound(NegotiationRound round) {
    _rounds.add(round);
    notifyListeners();
  }

  void clearRounds() {
    _rounds.clear();
    notifyListeners();
  }
}
