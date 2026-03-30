import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


List<String> images = [
  "assets/images/onboarding_one.png",
  "assets/images/onboarding_two.png",
  "assets/images/onboarding_three.png",
];

class Onboardingslidertwo extends StatelessWidget {
  const Onboardingslidertwo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          SizedBox(
            height: ScreenUtil().screenHeight * 0.5,
            width: ScreenUtil().screenWidth,
            child: ImageSlideshow(
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().screenHeight,
              indicatorColor: Kolors.kGray,
              indicatorBackgroundColor: Colors.grey,
              onPageChanged: (p) {
                if (kDebugMode) {
                  print("Page changed: $p");
                }
              },
              autoPlayInterval: 5000,
              isLoop: true,
              children: images.map((path) {
                return Image.asset(
                  path,
                  fit: BoxFit.fill,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
