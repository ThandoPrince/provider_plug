// lib/screens/splash/views/bridge_splash.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/storage.dart';
import 'package:flutter_application_2/common/utils/app_routes.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BridgeSplash extends StatefulWidget {
  const BridgeSplash({super.key});

  @override
  State<BridgeSplash> createState() => _BridgeSplashState();
}

class _BridgeSplashState extends State<BridgeSplash> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Wait for first frame to render (native splash still visible)
    await Future.microtask(() {});
    
    if (!mounted) return;
    
    // Determine route (same logic as getInitialRoute)
    final isFirstTime = Storage().getBool('isFirstTimeProvider') ?? true;
    final auth = context.read<AuthSessionController>();
    
    // Ensure session is loaded (should be from initializeCore, but safe)
    await auth.loadSession();
    
    String targetRoute;
    if (isFirstTime) {
      targetRoute = '/onboarding';
    } else if (auth.isLoggedIn) {
      targetRoute = '/entrypoint';
    } else {
      targetRoute = '/login';
    }
    
    // NOW remove native splash - transition to Flutter UI
    FlutterNativeSplash.remove();
    
    // Navigate to target route
    if (mounted) {
      context.go(targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This renders WHILE native splash is still visible
    // User sees: Native Splash → (instant) → This screen → Target Route
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your app icon - matches native splash icon
              Image.asset(
                'assets/icons/plug_provider_foreground.png',
                width: 120.w,
                height: 120.w,
              ),
              SizedBox(height: 24.h),
              // Subtle loading indicator
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}