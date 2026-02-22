// ignore_for_file: unused_element


import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/screens/auth/views/address_creation_screen.dart';
import 'package:flutter_application_2/screens/auth/views/auth_creation_screen.dart';
import 'package:flutter_application_2/screens/auth/views/create_profile_screen.dart';
import 'package:flutter_application_2/screens/auth/views/create_service_screen.dart';
import 'package:flutter_application_2/screens/auth/views/login_screen.dart';
import 'package:flutter_application_2/screens/auth/views/select_service_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/home/views/home_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_2/screens/onboarding/views/onboarding_screen.dart';
import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


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
      path: '/auth_registration',
      builder: (context, state) => const AuthCreationScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const SPLoginScreen(),
    ),

     GoRoute(
  path: '/sp_patch/:email',
  builder: (context, state) {
    final email = state.pathParameters['email']!; // ✅ Use pathParameters
    return SPProfilePatchScreen(email: email);
  },
),
GoRoute(
  path: '/sp_address_document/:email',
  builder: (context, state) {
    final email = state.pathParameters['email']!;
    return SPAddressDocumentScreen(email: email);
  },
),

GoRoute(
  path: '/sp_select_service/:email',
  builder: (context, state) {
    final email = state.pathParameters['email']!;
    return SelectServiceScreen(providerEmail: email);
  },
),

GoRoute(
  path: '/sp_add_service/:email',
  builder: (context, state) {
    final email = state.pathParameters['email']!;
    return CreateServiceScreen(providerEmail: email);
  },
),

            GoRoute(
  path: '/home',
  builder: (context, state) {
    final auth = context.watch<AuthSessionController>();
    final email = auth.email ?? '';

    return HomeScreen(email: email);
  },
),

  ],
);

GoRouter get router => _router;
