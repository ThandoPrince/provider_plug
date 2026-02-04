import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_model.dart';
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

  String _key(int orderId, String email) =>
      '$orderId|${email.trim().toLowerCase()}';

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
    required String email,
    bool forceRefresh = false,
  }) async {
    final key = _key(orderId, email);

    // Prevent duplicate requests unless forced
    if (isLoading(key)) return;
    if (!forceRefresh && _negotiationsMap.containsKey(key)) return;

    _setLoading(key, true);
    _errorMap[key] = null;

    try {
      final fetched = await GetSpNegotiationApi.fetchNegotiations(
        orderId: orderId,
        email: email,
      );

      _negotiationsMap[key] = fetched;

      if (fetched.isEmpty) {
        _errorMap[key] = 'No negotiations found';
      }
    } catch (e) {
      _negotiationsMap[key] = [];
      _errorMap[key] = e.toString();
    } finally {
      _setLoading(key, false);
    }
  }

  /// 🔥 Force refresh (used after Send / Accept)
  Future<void> refreshNegotiations({
    required int orderId,
    required String email,
  }) async {
    final key = _key(orderId, email);

    // Keep old data while refreshing (important for AnimatedList)
    _errorMap[key] = null;
    notifyListeners();

    await loadNegotiations(
      orderId: orderId,
      email: email,
      forceRefresh: true,
    );
  }

  /// Clear a specific negotiation cache
  void clearNegotiation({
    required int orderId,
    required String email,
  }) {
    final key = _key(orderId, email);
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
