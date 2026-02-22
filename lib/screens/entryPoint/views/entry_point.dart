import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_2/screens/entryPoint/home/views/home_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/profile/profile_screen.dart';
import 'package:flutter_application_2/screens/scheduled_services/views/scheduled_services_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/widgets/custom_app_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';


class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Make sure session is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthSessionController>();
      auth.loadSession();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionController>();
    final email = auth.email;

    // Show loading if session is not ready
    if (email == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Pages now dynamically use the logged-in email
    final pages = [
      HomeScreen(email: email),
      ScheduledOrdersScreen(email: email),
      SpProfileScreen(email: email),
    ];

    return Consumer<TabIndexNotifier>(
      builder: (context, tabNotifier, _) {
        return WillPopScope(
          onWillPop: () async {
            if (tabNotifier.index != 0) {
              tabNotifier.setIndex(0);
              _pageController.jumpToPage(0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: tabNotifier.index == 0 ? const CustomAppBar() : null,

            // --- Drawer ---
            drawer: Drawer(
              backgroundColor: Kolors.kOffWhite,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Kolors.kPrimary),
                    child: Text(
                      'Provider Menu',
                      style: appStyle(16, Colors.white, FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('My Job History'),
                    onTap: () {
                      Navigator.pop(context);
                      tabNotifier.setIndex(0);
                      _pageController.jumpToPage(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.build_circle_outlined),
                    title: const Text('My Linked Services'),
                    onTap: () {
                      Navigator.pop(context);
                      tabNotifier.setIndex(1);
                      _pageController.jumpToPage(1);
                    },
                  ),
                ],
              ),
            ),

            // --- PageView ---
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: tabNotifier.setIndex,
                children: pages,
              ),
            ),

            // --- Bottom Navigation ---
            bottomNavigationBar: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(30),
              ),
              child: GNav(
                selectedIndex: tabNotifier.index,
                onTabChange: (index) {
                  tabNotifier.setIndex(index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                gap: 8,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                duration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                color: Colors.grey.shade400,
                activeColor: Colors.white,
                tabBackgroundColor: Kolors.kPrimary.withOpacity(0.4),
                tabs: const [
                  GButton(icon: Ionicons.home_outline, text: 'Home'),
                  GButton(icon: Icons.volunteer_activism_outlined, text: 'Scheduled'),
                  GButton(icon: Ionicons.person_outline, text: 'Profile'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}