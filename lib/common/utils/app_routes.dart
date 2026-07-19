import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/screens/auth/views/address_creation_screen.dart';
import 'package:flutter_application_2/screens/auth/views/auth_creation_screen.dart';
import 'package:flutter_application_2/screens/auth/views/cost_of_service_creation.dart';
import 'package:flutter_application_2/screens/auth/views/create_profile_screen.dart';
import 'package:flutter_application_2/screens/auth/views/create_service_screen.dart';
import 'package:flutter_application_2/screens/auth/views/login_screen.dart';
import 'package:flutter_application_2/screens/auth/views/select_service_screen.dart';
import 'package:flutter_application_2/screens/auth/views/upload_affidavit_screen.dart';
import 'package:flutter_application_2/screens/completed_services/views/completed_services_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/home/views/home_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/select_service/views/cost_of_a_service_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/select_service/views/create_a_service_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/select_service/views/select_a_service_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/linked_services/views/linked_services_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/privacy_policy.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/terms_of_service_screen.dart';
import 'package:flutter_application_2/screens/onboarding/views/onboarding_screen.dart';
import 'package:flutter_application_2/screens/splash/views/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

//     GoRoute(
//   path: '/reset_password',
//   builder: (context, state) => const ResetPasswordScreen(),
// ),

    GoRoute(
      path: '/welcome',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: '/entrypoint',
      builder: (context, state) => const EntryPoint(),
    ),
    GoRoute(
  path: '/providers/services/:serviceId/affidavit',
  builder: (context, state) => UploadAffidavitScreen(
    
    serviceId: state.pathParameters['serviceId']!,
  ),
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
      path: '/sp_patch',
      builder: (context, state) {
        
        return SPProfilePatchScreen();
      },
    ),

    GoRoute(
      path: '/providers/services/:serviceId/cost',
      builder: (context, state) {
        
        final serviceId = int.parse(state.pathParameters['serviceId']!);
       
        return UploadServiceCostScreen( serviceId: serviceId);
      },
    ),

    GoRoute(
      path: '/providers/add/:serviceId/cost',
      builder: (context, state) {
       
        final serviceId = int.parse(state.pathParameters['serviceId']!);
        return CreateACostOfServiceScreen( serviceId: serviceId);
      },
    ),

    GoRoute(
      path: '/sp_address_document',
      builder: (context, state) {
        
        return SPAddressDocumentScreen();
      },
    ),

    GoRoute(
      path: '/sp_completed_service',
      builder: (context, state) {
        
        return ProviderRatingsScreen();
      },
    ),

    GoRoute(
      path: '/sp_select_service',
      builder: (context, state) {
       
        return SelectServiceScreen();
      },
    ),

    GoRoute(
      path: '/sp_add_service',
      builder: (context, state) {
        
        return CreateServiceScreen();
      },
    ),

    GoRoute(
      path: '/sp_add_a_service',
      builder: (context, state) {
        
        return CreateAServiceScreen();
      },
    ),

    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),

    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),

    GoRoute(
      path: '/provider_linked_services',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ProviderLinkedServicesScreen(email: email);
      },
    ),

    GoRoute(
      path: '/sp_select_a_service',
      builder: (context, state) {
        
        return SelectAServiceScreen();
      },
    ),
  ],
);

GoRouter get router => _router;