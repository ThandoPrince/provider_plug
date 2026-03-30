import 'dart:ui';
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
import 'package:go_router/go_router.dart';
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

  Widget _buildDrawerTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    leading: Icon(icon, color: Kolors.kPrimary, size: 24),
    title: Text(
      title,
      style: appStyle(14, Colors.white, FontWeight.w500),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    onTap: onTap,
    hoverColor: Kolors.kPrimary.withOpacity(0.1),
  );
}

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionController>();
    final email = auth.email;

    if (email == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pages = [
      HomeScreen(email: email),
      ScheduledOrdersScreen(email: email),
      SpProfileScreen(email: email),
    ];

    return Consumer<TabIndexNotifier>(
      builder: (context, tabNotifier, _) {
        final bool isHome = tabNotifier.index == 0;

        return WillPopScope(
          onWillPop: () async {
            if (!isHome) {
              tabNotifier.setIndex(0);
              _pageController.jumpToPage(0);
              return false;
            }
            return true;
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              extendBody: true,
              appBar: isHome ? const CustomAppBar() : null,

              drawer: Drawer(
  backgroundColor: const Color(0xFF1A1A1A), // Matches the dark end of your gradient
  child: Column(
    children: [
      // --- CUSTOM DRAWER HEADER ---
      UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.white, size: 40),
        ),
        accountName: Text(
          'Provider Portal',
          style: appStyle(18, Colors.white, FontWeight.bold),
        ),
        accountEmail: Text(
          email, // Using the email variable from your build method
          style: appStyle(12, Colors.white70, FontWeight.normal),
        ),
      ),

      // --- DRAWER ITEMS ---
      Expanded(
        child: Container(
          color: const Color(0xFF1A1A1A),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              const SizedBox(height: 10),
              _buildDrawerTile(
                icon: Icons.history_rounded,
                title: 'My Job History',
                onTap: () {
                   Navigator.pop(context);
                  context.push('/sp_completed_service/$email');
                },
              ),
              _buildDrawerTile(
                icon: Icons.build_circle_outlined,
                title: 'My Linked Services',
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/provider_linked_services?email=${Uri.encodeComponent(email)}',
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(color: Colors.white10),
              ),
              
            ],
          ),
        ),
      ),

      // --- BOTTOM SECTION ---
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "v1.0.0",
          style: appStyle(10, Colors.white24, FontWeight.normal),
        ),
      ),
    ],
  ),
),

              body: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: tabNotifier.setIndex,
                children: pages,
              ),

              bottomNavigationBar: _buildBottomNav(tabNotifier),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(TabIndexNotifier tabNotifier) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Kolors.kDark,
          child: SafeArea(
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 4,
              activeColor: Kolors.kPrimary,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              duration: const Duration(milliseconds: 350),
              tabBackgroundColor: Kolors.kPrimary.withOpacity(0.1),
              color: Kolors.kOffWhite.withOpacity(0.6),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              tabs: const [
                GButton(icon: Ionicons.home_outline, text: 'Home'),
                GButton(
                  icon: Icons.volunteer_activism_outlined,
                  text: 'Scheduled',
                ),
                GButton(icon: Ionicons.person_outline, text: 'Profile'),
              ],
              selectedIndex: tabNotifier.index,
              onTabChange: (index) {
                tabNotifier.setIndex(index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}