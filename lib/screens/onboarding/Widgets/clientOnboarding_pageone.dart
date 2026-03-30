import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/storage.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final bool isFirstTime =
        Storage().getBool('isFirstTimeProvider') ?? true;

    if (isFirstTime) {
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
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),
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
                Expanded(
                  flex: 3,
                  child: _buildHeroImage(),
                ),
                SizedBox(height: 40.h),
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
                SizedBox(height: 140.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double imageWidth = 570;
        const double imageHeight = 1198;
        final double targetHeight = MediaQuery.of(context).size.height * 0.58;

        return Center(
          child: Container(
            height: targetHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Image.asset(
                    'assets/images/provider_welcome.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}