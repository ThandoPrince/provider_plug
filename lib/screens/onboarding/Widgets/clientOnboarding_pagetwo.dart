import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/Onboarding/Widgets/OnboardingSliderTwo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreenTwo extends StatefulWidget {
  const OnboardingScreenTwo({super.key});

  @override
  State<OnboardingScreenTwo> createState() => _OnboardingScreenTwoState();
}

class _OnboardingScreenTwoState extends State<OnboardingScreenTwo> {
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
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)], // Matching Screen One
          ),
        ),
        child: SafeArea(
          bottom: false, // Leave room for the dot indicator stack
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),

                // --- High-Value Headline ---
                Text(
                  'Infinite Reach.\nZero Boundaries.',
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

                // --- Hero Section (The Slider) ---
                Expanded(
                  flex: 3,
                  child: Container(
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
                      child: const Onboardingslidertwo(), 
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // --- Value Prop Label ---
                Text(
                  'CUSTOMIZABLE SKILLSETS',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),

                SizedBox(height: 15.h),

                // --- Punchy Body Text ---
                Text(
                  'List your expertise in beauty, repairs, or cleaning. Don’t see your niche? Add your own custom skill and define your own market.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                // --- Spacing for Dot Indicators ---
                // Matches the height from Screen One to keep the transition smooth
                SizedBox(height: 140.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}