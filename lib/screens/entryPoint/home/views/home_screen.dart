import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_active_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/controller/sp_live_location_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/entryPoint/home/widgets/home_body_widget.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/back_exit_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  
final int providerID;
  const HomeScreen({
    super.key,
    required this.providerID,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SPBookingController? _bookingController;
  SpLiveLocationPostController? _locationController;
  ProviderActiveController? _activeController;
  SpProfileCtrl? _profileController;

  bool _showHeader = true;
  bool _isInitializing = true;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeControllers();
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final providerID = AuthSessionController.instance.id;

    if (oldWidget.providerID != widget.providerID) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _reinitializeForNewEmail();
      });
    }
  }

  Future<void> _initializeControllers() async {
  if (!mounted) return;

  _bookingController = context.read<SPBookingController>();
  _locationController = context.read<SpLiveLocationPostController>();
  _activeController = context.read<ProviderActiveController>();
  _profileController = context.read<SpProfileCtrl>();

  _bookingController?.removeListener(_bookingErrorListener);
  _activeController?.removeListener(_providerStatusListener);

  _bookingController?.addListener(_bookingErrorListener);
  _activeController?.addListener(_providerStatusListener);

  // Connect websocket immediately after login.
await _loadInitialProviderStatusAndSync();

await _bookingController?.startRealtime(widget.providerID);

  if (!mounted) return;

  AuthSessionController.instance.markLoggedIn();

  setState(() {
    _isInitializing = false;
  });
}

  Future<void> _reinitializeForNewEmail() async {
   
    _locationController?.stopTracking();

    _lastShownError = null;

    if (!mounted) return;

    setState(() {
      _isInitializing = true;
    });

    await _loadInitialProviderStatusAndSync();

    if (!mounted) return;

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _loadInitialProviderStatusAndSync() async {
    final profileCtrl = _profileController;
    final activeCtrl = _activeController;

    if (profileCtrl == null || activeCtrl == null) return;

    await profileCtrl.fetchSPByEmail();

    if (!mounted) return;

    final profile = profileCtrl.spProfile;
    if (profile != null) {
      activeCtrl.setInitialStatus(profile.isActive);
      await _syncOnlineState(profile.isActive);
    } else {
      await _syncOnlineState(false);
    }
  }

  Future<void> _syncOnlineState(bool isOnline) async {
  debugPrint("🏠 _syncOnlineState(isOnline=$isOnline)");

  final locationCtrl = _locationController;

  if (locationCtrl == null) {
    debugPrint("❌ locationCtrl is null");
    return;
  }

  if (isOnline) {
    final providerID = AuthSessionController.instance.id;

    debugPrint("▶️ Calling startTracking($providerID)");

    await locationCtrl.startTracking(
      providerId: providerID!,
      intervalSeconds: 30,
    );
  } else {
    debugPrint("⏹️ Calling stopTracking()");
    locationCtrl.stopTracking();
  }
}

 void _providerStatusListener() {
  debugPrint(
    "📢 Provider status changed: ${_activeController?.isActive}",
  );

  final activeCtrl = _activeController;
  if (activeCtrl == null || !mounted) return;

  _syncOnlineState(activeCtrl.isActive);
}

  void _bookingErrorListener() {
    final bookingCtrl = _bookingController;
    if (bookingCtrl == null || !mounted) return;

    final error = bookingCtrl.errorMessage;
    if (error == null || error.isEmpty) return;
    if (_lastShownError == error) return;

    _lastShownError = error;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return;

    final delta = notification.scrollDelta ?? 0;

    if (delta > 0 && _showHeader) {
      setState(() => _showHeader = false);
    } else if (delta < 0 && !_showHeader) {
      setState(() => _showHeader = true);
    }
  }

  @override
  void dispose() {
    _bookingController?.removeListener(_bookingErrorListener);
    _activeController?.removeListener(_providerStatusListener);

    
    _locationController?.stopTracking(notify: false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isInitializing
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _showHeader ? 80 : 0,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Active Bookings",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          _onScroll(notification);
                          return false;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Kolors.kOffWhite.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: HomeBodyWidget(),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}