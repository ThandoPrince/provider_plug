import 'package:flutter/material.dart';

import 'package:flutter_application_2/screens/Onboarding/widgets/clientOnboarding_pageone.dart';
import 'package:flutter_application_2/screens/Onboarding/widgets/clientOnboarding_pagetwo.dart';
import 'package:flutter_application_2/screens/Onboarding/widgets/clientOnboarding_pagethree.dart';
import 'package:flutter_application_2/screens/onboarding/controllers/onboarding_notifiers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
late final PageController _pageController;

@override
void initState() {
  super.initState();
    _pageController = PageController(
      initialPage: context.read<OnboardingNotifier>().getSelectedPage,
    );
}

  @override
  Widget build(BuildContext context) {
    int currentPage = context.watch<OnboardingNotifier>().getSelectedPage;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              context.read<OnboardingNotifier>().setSelectedPage = page;
            },
            children: const [
              OnboardingScreenOne(),
              OnboardingScreenTwo(),
              OnboardingScreenThree(),
            ],
          ),

          // Page Indicator + Arrows
          currentPage == 2
              ? const SizedBox.shrink()
              : Positioned(
                  bottom: 50.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    width: ScreenUtil().screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        currentPage == 0
                            ? SizedBox(width: 25.w)
                            : GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    currentPage - 1,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                },
                                child: const Icon(
                                  AntDesign.leftcircle,
                                  size: 30,
                                  color: Colors.blueGrey,
                                ),
                              ),

                        // Dot Indicator
                        SizedBox(
                          width: ScreenUtil().screenWidth * 0.6,
                          height: 50.h,
                          child: PageViewDotIndicator(
                            currentItem: currentPage,
                            count: 3,
                            unselectedColor: Colors.white,
                            selectedColor: Colors.blueGrey,
                            duration: const Duration(milliseconds: 200),
                            onItemClicked: (index) {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),

                        // Next button
                        GestureDetector(
                          onTap: () {
                            if (currentPage < 2) {
                              _pageController.animateToPage(
                                currentPage + 1,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          child: const Icon(
                            AntDesign.rightcircle,
                            size: 30,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
