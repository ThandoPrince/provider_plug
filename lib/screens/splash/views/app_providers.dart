import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/auth/get_provider_for_service_controller.dart';
import 'package:flutter_application_2/common/controller/auth/sp_login_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/booking_by_orderID_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/get_shipment_route_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/negotiation_rounds_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/session_by_shipment_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/session_status_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_by_id_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_route_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_accept_negotiation_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiation_round_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/controller/bookings/update_ratings_controller.dart';
import 'package:flutter_application_2/common/controller/registration/address_id_doc_controller.dart';
import 'package:flutter_application_2/common/controller/registration/cost_of_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_approved_services_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_auth_controller.dart';
import 'package:flutter_application_2/common/controller/registration/fetch_service_group_by_controller.dart';
import 'package:flutter_application_2/common/controller/registration/link_service_controller.dart';
import 'package:flutter_application_2/common/controller/registration/login_creation_controller.dart';
import 'package:flutter_application_2/common/controller/registration/profile_creation_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/completed_services_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/cost_of_a_service_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_active_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/controller/sp_live_location_controller.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/drawer_notifier.dart';
import 'package:flutter_application_2/screens/onboarding/controllers/onboarding_notifiers.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<LoginCreationController>(
          create: (_) => LoginCreationController(),
        ),
        ChangeNotifierProvider<SPLoginController>(
          create: (_) => SPLoginController(),
        ),
        ChangeNotifierProvider<GetProviderForServiceController>(
          create: (_) => GetProviderForServiceController(),
        ),
        ChangeNotifierProvider<FetchAuthController>(
          create: (_) => FetchAuthController(),
        ),
        ChangeNotifierProvider<AuthSessionController>(
          create: (_) => AuthSessionController.instance,
        ),
        ChangeNotifierProvider<SPProfileCreationController>(
          create: (_) => SPProfileCreationController(),
        ),
        ChangeNotifierProvider<CostOfServiceController>(
          create: (_) => CostOfServiceController(),
        ),
        ChangeNotifierProvider<SPAddressDocumentController>(
          create: (_) => SPAddressDocumentController(),
        ),
        ChangeNotifierProvider<FetchApprovedServicesController>(
          create: (_) => FetchApprovedServicesController(),
        ),
        ChangeNotifierProvider<FetchServiceGroupByController>(
          create: (_) => FetchServiceGroupByController(),
        ),
        ChangeNotifierProvider<ProviderActiveController>(
          create: (_) => ProviderActiveController(),
        ),
        ChangeNotifierProvider<LinkServiceController>(
          create: (_) => LinkServiceController(),
        ),
        ChangeNotifierProvider<TabIndexNotifier>(
          create: (_) => TabIndexNotifier(),
        ),
        ChangeNotifierProvider<DrawerNotifier>(
          create: (_) => DrawerNotifier(),
        ),
        ChangeNotifierProvider<OnboardingNotifier>(
          create: (_) => OnboardingNotifier(),
        ),
        ChangeNotifierProvider<SPBookingController>(
          create: (_) => SPBookingController(),
        ),
        ChangeNotifierProvider<BookingByOrderIDController>(
          create: (_) => BookingByOrderIDController(),
        ),
        ChangeNotifierProvider<SpProfileCtrl>(
          create: (_) => SpProfileCtrl(),
        ),
        ChangeNotifierProvider<SpNegotiationsByIdEmailCtrl>(
          create: (_) => SpNegotiationsByIdEmailCtrl(),
        ),
        ChangeNotifierProvider<SpNegotiationRoundCtrl>(
          create: (_) => SpNegotiationRoundCtrl(),
        ),
        ChangeNotifierProvider<NegotiationRoundsCtrl>(
          create: (_) => NegotiationRoundsCtrl(),
        ),
        ChangeNotifierProvider<ProviderAcceptNegotiationCtrl>(
          create: (_) => ProviderAcceptNegotiationCtrl(),
        ),
        ChangeNotifierProvider<ShipmentController>(
          create: (_) => ShipmentController(),
        ),
        ChangeNotifierProvider<SpLiveLocationPostController>(
          create: (_) => SpLiveLocationPostController(),
        ),
        ChangeNotifierProvider<ShipmentRouteController>(
          create: (_) => ShipmentRouteController(),
        ),
        ChangeNotifierProvider<SessionByShipmentController>(
          create: (_) => SessionByShipmentController(),
        ),
        ChangeNotifierProvider<SessionLocationPingController>(
          create: (_) => SessionLocationPingController(),
        ),
        ChangeNotifierProvider<SessionStatusController>(
          create: (_) => SessionStatusController(),
        ),
        ChangeNotifierProvider<RatingController>(
          create: (_) => RatingController(),
        ),
        ChangeNotifierProvider<ShipmentRouteFetchController>(
          create: (_) => ShipmentRouteFetchController(),
        ),
        ChangeNotifierProvider<CostOfAServiceController>(
          create: (_) => CostOfAServiceController(),
        ),
        ChangeNotifierProvider<ProviderRatingsController>(
          create: (_) => ProviderRatingsController(),
        ),
        ChangeNotifierProvider<ShipmentByIdController>(
          create: (_) => ShipmentByIdController(),
        ),
      ];
}