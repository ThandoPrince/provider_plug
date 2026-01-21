  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_application_2/common/storage.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:go_router/go_router.dart';

  class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    State<SplashScreen> createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen> {
    late Timer _timer;

    @override
    void initState() {
      super.initState();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

      _timer = Timer(const Duration(seconds: 3), () {
        bool? firstOpen = Storage().getBool('firstOpen');
        if (firstOpen == null || firstOpen == false) {
          GoRouter.of(context).go('/onboarding');
          
        } else {
          GoRouter.of(context).go('/welcome');
        }
      });
    }
    @override
      void dispose() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      _timer.cancel();
      super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.white],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                child: Image.asset(
                  'assets/icons/plug_icon.png',
                ),
              ),

              const SizedBox(height: 20),
              const SizedBox(
                height: 20,
                width: 30,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change the game!',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
