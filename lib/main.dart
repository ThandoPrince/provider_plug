import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/utils/app_initializer.dart';
import 'package:flutter_application_2/common/utils/app_routes.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/splash/views/app_providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await AppInitializer.initializeCore();

 bool _handlingSessionExpiry = false;

ApiClient.instance.setSessionExpiredHandler(() async {
  if (_handlingSessionExpiry) return;

  _handlingSessionExpiry = true;

  debugPrint("🔐 Session expired — forcing logout");

  try {
    await AuthSessionController.instance.clearSession();
  } catch (e) {
    debugPrint("⚠️ Failed to clear session: $e");
  }

  // Give any pending callbacks a chance to finish.
  await Future<void>.delayed(Duration.zero);

  router.go('/login');

  _handlingSessionExpiry = false;
});

  runApp(
    MultiProvider(
      providers: AppProviders.providers,
      child: const MainApp(),
    ),
  );

  // Everything network/permission/plugin related — fire after first frame,
  // each with its own timeout + error handling so one bad call can't hang forever
  AppInitializer.initializeDeferred();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, __) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Colors.white,
            ),
          ),
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Kolors.kPrimary,
                    Color(0xFF1A1A1A),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}