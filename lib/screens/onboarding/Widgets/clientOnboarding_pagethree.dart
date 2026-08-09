import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/storage.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/custom_button.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreenThree extends StatefulWidget {
  const OnboardingScreenThree({super.key});

  @override
  State<OnboardingScreenThree> createState() => _OnboardingScreenThreeState();
}

class _OnboardingScreenThreeState extends State<OnboardingScreenThree> {
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermissions();
  }

  Future<void> _requestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _handleGetStarted() async {
  if (!_isAgreed) {
    FlushbarService.error(
      context,
      "Please accept the Terms of Use to continue.",
    );
    return;
  }

  final status = await Permission.locationWhenInUse.request();

  if (status.isGranted) {
    HapticFeedback.heavyImpact();

    Storage().setBool(
      'isFirstTimeProvider',
      false,
    );

    if (!mounted) return;

    context.go("/auth_registration");
  } else {
    FlushbarService.error(
      context,
      "Location access is required to find jobs in your area.",
    );
  }
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Kolors.kPrimary, Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    MaterialCommunityIcons.shield_check_outline,
                    size: 80.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  'Build Your Reputation.\nScale Your Income.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.5,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'Plug simplifies finding clients, managing bookings, and getting paid. Focus on your craft; we’ll handle the rest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                _buildTermsSection(),
                SizedBox(height: 25.h),
                GradientBtn(
                  text: "GET STARTED",
                  onTap: _handleGetStarted,
                  btnColor: _isAgreed ? Kolors.kPrimary : Colors.white10,
                  radius: 18,
                  btnHieght: 62,
                  btnWidth: double.infinity,
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: _isAgreed,
            activeColor: Kolors.kPrimary,
            checkColor: Colors.white,
            side: BorderSide(color: Colors.white24, width: 2.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (val) {
              HapticFeedback.lightImpact();
              setState(() => _isAgreed = val ?? false);
            },
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white38,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: "I agree to the "),
                TextSpan(
                  text: "Terms of Service",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.push('/terms');
                    },
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.push('/privacy');
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}