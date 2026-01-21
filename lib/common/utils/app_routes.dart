// ignore_for_file: unused_element


import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/entryPoint/home/views/home_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_2/screens/onboarding/views/onboarding_screen.dart';
import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';

import 'package:go_router/go_router.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final GoRouter _router = GoRouter(
   navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [

    GoRoute(
  path: '/',
  builder: (context, state) => const SplashScreen(), // or your app's home screen
),

    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

        GoRoute(
      path: '/welcome',
      builder: (context, state) => const OnboardingScreen(),
    ),

            GoRoute(
      path: '/entrypoint',
      builder: (context, state) => const EntryPoint(),
    ),

            GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(email: "nomfundomabunda748@gmail.com"),
    ),

  ],
);

GoRouter get router => _router;
