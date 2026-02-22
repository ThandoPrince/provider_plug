import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTimeProvider');

    if (isFirstTime == null || isFirstTime == true) {
      if (mounted) setState(() => _loading = false);
    } else {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A), 
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          bottom: false, // Parent wrapper handles the bottom safe area/dots
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),

                // --- High-Value Headline ---
                Text(
                  'Master Your Craft.\nOwn Your Time.',
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.5,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // --- Hero Section (GIF/Image) ---
                Expanded(
                  flex: 3,
                  child: _buildHeroSection(),
                ),

                SizedBox(height: 40.h),

                // --- Provider Value Proposition ---
                Text(
                  'THE ULTIMATE WORKSPACE',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                
                SizedBox(height: 15.h),

                Text(
                  'Join an elite network of pros. Get discovered by local clients, manage bookings, and grow your income—all in one place.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                // --- THE "DO THE RIGHT THING" SPACER ---
                // This ensures your content stays above the Dots and Arrows in the parent Stack
                SizedBox(height: 140.h), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35.r),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/provider_welcome.gif', 
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}