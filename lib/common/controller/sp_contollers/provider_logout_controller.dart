
import 'package:flutter/foundation.dart';

import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/sp_live_location_controller.dart';
import 'package:flutter_application_2/common/services/provider_logout_api.dart';

class ProviderLogoutController extends ChangeNotifier {
  final SpLiveLocationPostController liveLocationController;
  final SPBookingController bookingController;

  ProviderLogoutController({
    required this.liveLocationController,
    required this.bookingController,
  });

  bool _isLoggingOut = false;
  String? _errorMessage;

  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

    _isLoggingOut = true;
    _errorMessage = null;
    notifyListeners();

    final auth = AuthSessionController.instance;

    try {
      /*
       * ------------------------------------------------------
       * 1. BLACKLIST REFRESH TOKEN
       * ------------------------------------------------------
       */

      final refreshToken = auth.refreshToken;

      if (refreshToken != null && refreshToken.isNotEmpty) {
        debugPrint("🔐 Blacklisting refresh token...");

        try {
          final result = await ProviderLogoutApi.logout(
            refreshToken: refreshToken,
          );

          if (result["success"] == true) {
            debugPrint("✅ Refresh token blacklisted.");
          } else {
            debugPrint(
              "⚠️ Server logout failed: ${result["message"]}",
            );
          }
        } catch (e) {
          // Do not prevent local cleanup if the API call fails.
          debugPrint(
            "⚠️ Could not blacklist refresh token: $e",
          );
        }
      }

      /*
       * ------------------------------------------------------
       * 2. STOP LIVE LOCATION TRACKING
       * ------------------------------------------------------
       */

      debugPrint(
        "📍 Stopping provider location tracking...",
      );

      await liveLocationController.stopTracking();

      debugPrint(
        "✅ Provider location tracking stopped.",
      );

      /*
       * ------------------------------------------------------
       * 3. STOP BOOKINGS REALTIME
       *
       * This stops:
       * - WebSocket
       * - polling
       * - ping timer
       * - reconnect timer
       * - health-check timer
       * - active bookings
       * ------------------------------------------------------
       */

      debugPrint(
        "🔌 Stopping booking realtime services...",
      );

      bookingController.stopRealtime(
        clearBookings: true,
      );

      debugPrint(
        "✅ Booking WebSocket and polling stopped.",
      );

      /*
       * ------------------------------------------------------
       * 4. CLEAR LOCAL AUTH SESSION
       * ------------------------------------------------------
       */

      debugPrint(
        "🔐 Clearing local authentication session...",
      );

      await auth.clearSession();

      debugPrint(
        "✅ Local authentication session cleared.",
      );

      /*
       * ------------------------------------------------------
       * 5. COMPLETE
       * ------------------------------------------------------
       */

      debugPrint(
        "🧹 Provider logout cleanup complete.",
      );

      return true;
    } catch (e, stack) {
      debugPrint(
        "❌ Provider logout exception: $e",
      );

      debugPrint("$stack");

      _errorMessage = "Logout encountered an error.";

      /*
       * ------------------------------------------------------
       * SAFETY CLEANUP
       *
       * Even if something above fails, make sure realtime
       * services are stopped and the local session is cleared.
       * ------------------------------------------------------
       */

      try {
        await liveLocationController.stopTracking();
      } catch (e) {
        debugPrint(
          "⚠️ Failed to stop location tracking: $e",
        );
      }

      try {
        bookingController.stopRealtime(
          clearBookings: true,
        );
      } catch (e) {
        debugPrint(
          "⚠️ Failed to stop booking realtime: $e",
        );
      }

      try {
        await auth.clearSession();
      } catch (e) {
        debugPrint(
          "⚠️ Failed to clear auth session: $e",
        );
      }

      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}

