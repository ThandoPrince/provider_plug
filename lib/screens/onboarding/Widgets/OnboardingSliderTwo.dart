import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

final List<String> images = [
  "assets/images/onboarding_one.png",
  "assets/images/onboarding_two.png",
  "assets/images/onboarding_three.png",
];

class OnboardingSliderTwo extends StatefulWidget {
  const OnboardingSliderTwo({super.key});

  @override
  State<OnboardingSliderTwo> createState() => _OnboardingSliderTwoState();
}

class _OnboardingSliderTwoState extends State<OnboardingSliderTwo> {
  final CarouselSliderController _controller = CarouselSliderController();

  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      _currentIndex = (_currentIndex + 1) % images.length;

      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _resetAutoPlay() {
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().screenHeight * 0.5,
      width: ScreenUtil().screenWidth,
      child: GestureDetector(
        onPanDown: (_) {
          // User touched the slider.
          // Restart the timer from zero.
          _resetAutoPlay();
        },
        child: CarouselSlider.builder(
          carouselController: _controller,
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            return Image.asset(
              images[index],
              fit: BoxFit.fill,
              width: double.infinity,
            );
          },
          options: CarouselOptions(
            height: ScreenUtil().screenHeight * 0.5,
            viewportFraction: 1,
            enlargeCenterPage: false,
            enableInfiniteScroll: true,
            autoPlay: false, // We control autoplay ourselves.
            onPageChanged: (index, reason) {
              _currentIndex = index;

              // If the user swiped manually,
              // restart the 5-second countdown.
              if (reason == CarouselPageChangedReason.manual) {
                _resetAutoPlay();
              }
            },
          ),
        ),
      ),
    );
  }
}