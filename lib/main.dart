import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/auth/sp_login_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/booking_by_orderID_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/get_shipment_route_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/update_ratings_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/negotiation_rounds_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/session_by_shipment_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/session_status_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_route_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_accept_negotiation_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiation_round_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/controller/registration/address_id_doc_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_approved_services_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_service_group_by_controller.dart';
import 'package:flutter_application_2/common/controller/registration/link_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/login_creation_controller.dart';
import 'package:flutter_application_2/common/controller/registration/profile_creation_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/controller/sp_live_location_controller.dart';
import 'package:flutter_application_2/common/utils/app_routes.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/drawer_notifier.dart';
import 'package:flutter_application_2/screens/onboarding/controllers/onboarding_notifiers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 bool envLoaded = await _safeLoadEnv();
  // Initialize HERE SDK
  bool hereSdkInitialized = await _safeInitializeHERESDK();

  // Load environment variables
 

  runApp(MyAppProviders(
    hereSdkInitialized: hereSdkInitialized,
    envLoaded: envLoaded,
  ));
}

Future<bool> _safeLoadEnv() async {

  final envFile = kReleaseMode ? ".env.production" : ".env.development";
 
  try {
    await dotenv.load(fileName: envFile);
    debugPrint("✅ Environment loaded from $envFile");
    return true;
  } catch (e, st) {
    debugPrint("⚠️ Could not load $envFile: $e\n$st");
    return false;
  }
}

/// Safe HERE SDK initialization
Future<bool> _safeInitializeHERESDK() async {
  final String hereAccessKeyID = dotenv.env['HEREACCESSKEYID'] ?? '';
  final String hereKeySecret = dotenv.env['HEREKEYSECRET'] ?? '';
  try {
    SdkContext.init(IsolateOrigin.main);

    String accessKeyId = hereAccessKeyID;
    String accessKeySecret =
        hereKeySecret;
    AuthenticationMode authMode =
        AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
    SDKOptions sdkOptions = SDKOptions.withAuthenticationMode(authMode);

    await SDKNativeEngine.makeSharedInstance(sdkOptions);

    debugPrint("✅ HERE SDK initialized successfully");
    return true;
  } catch (e, st) {
    debugPrint("❌ HERE SDK initialization failed: $e\n$st");
    return false;
  }
}

/// Safe environment loading


class MyAppProviders extends StatelessWidget {
  final bool hereSdkInitialized;
  final bool envLoaded;

  const MyAppProviders({
    super.key,
    required this.hereSdkInitialized,
    required this.envLoaded,
  });

  @override
  Widget build(BuildContext context) {
    if (!hereSdkInitialized || !envLoaded) {
      // Show a friendly error screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              "⚠️ Initialization failed.\nCheck logs for details.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.sp),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginCreationController()),
        ChangeNotifierProvider(create: (_) => SPLoginController()),
        ChangeNotifierProvider(create: (_) => AuthSessionController.instance),
        ChangeNotifierProvider(create: (_) => SPProfileCreationController()),
        ChangeNotifierProvider(create: (_) => SPAddressDocumentController()),
        ChangeNotifierProvider(create: (_) => FetchApprovedServicesController()),
        ChangeNotifierProvider(create: (_) => FetchServiceGroupByController()),
        ChangeNotifierProvider(create: (_) => LinkServiceController()),
        ChangeNotifierProvider(create: (_) => TabIndexNotifier()),
        ChangeNotifierProvider(create: (_) => DrawerNotifier()),
        ChangeNotifierProvider(create: (_) => OnboardingNotifier()),
        ChangeNotifierProvider(create: (_) => SPBookingController()),
        ChangeNotifierProvider(create: (_) => BookingByOrderIDController()),
        ChangeNotifierProvider(create: (_) => SpProfileCtrl()),
        ChangeNotifierProvider(create: (_) => SpNegotiationsByIdEmailCtrl()),
        ChangeNotifierProvider(create: (_) => SpNegotiationRoundCtrl()),
        ChangeNotifierProvider(create: (_) => NegotiationRoundsCtrl()),
        ChangeNotifierProvider(create: (_) => ProviderAcceptNegotiationCtrl()),
        ChangeNotifierProvider(create: (_) => ShipmentController()),
        ChangeNotifierProvider(create: (_) => SpLiveLocationPostController()),
        ChangeNotifierProvider(create: (_) => ShipmentRouteController()),
        ChangeNotifierProvider(create: (_) => SessionByShipmentController()),
        ChangeNotifierProvider(create: (_) => SessionLocationPingController()),
        ChangeNotifierProvider(create: (_) => SessionStatusController(),),
        ChangeNotifierProvider(create: (_) => RatingController(),),
        ChangeNotifierProvider(create: (_) => ShipmentRouteFetchController(),),

        
      ],
      child: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        try {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        } catch (e, st) {
          debugPrint("❌ MaterialApp.router failed: $e\n$st");
          // fallback page
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text(
                  "⚠️ Router initialization failed.\nCheck logs.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
