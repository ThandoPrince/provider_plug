import 'dart:ui';

import 'package:another_flushbar/another_flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_active_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_logout_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
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
  late final List<Widget> _pages;

  @override
void initState() {
  super.initState();

  _pageController = PageController();

  final providerID = AuthSessionController.instance.id!;

  _pages = [
    HomeScreen(providerID: providerID),
    ScheduledOrdersScreen(providerID: providerID),
    SpProfileScreen(),
  ];

  WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<AuthSessionController>().loadSession();

  final shipmentCtrl = context.read<ShipmentController>();
  debugPrint(
    "EntryPoint ShipmentController: ${shipmentCtrl.hashCode}",
  );

  shipmentCtrl.fetchShipments();

  context.read<SpProfileCtrl>().fetchSPByEmail();
});
}

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
  final logoutController =
      context.read<ProviderLogoutController>();

  final success = await logoutController.logout();
 

  if (!mounted) return;

  if (success) {
    ProviderActiveController.instance.reset();
     Provider.of<TabIndexNotifier>(context, listen: false).reset();

    context.go('/login');

    debugPrint(
      "Service Provider logged out successfully",
    );
  } else {
    FlushbarService.error(
      context,
      logoutController.errorMessage ??
          "Logout failed. Please try again.",
    );
  }
}

Future<void> _confirmLogout(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 26,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 50,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Kolors.kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Kolors.kOffWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (result == true) {
    _logout();
  }
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
    final id = auth.id != null ? auth.accessToken : null; // Use accessToken as a placeholder for email

    if (id == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    return Consumer<TabIndexNotifier>(
      builder: (context, tabNotifier, _) {
        final bool isHome = tabNotifier.index == 0;
        final profileCtrl = context.watch<SpProfileCtrl>();
    final profile = profileCtrl.spProfile;
    
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
      InkWell(
        onTap: () {
        Navigator.pop(context);
    
        tabNotifier.setIndex(2);
    
        _pageController.animateToPage(
    2,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
        );
      },
        child: UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: profile != null &&
          profile.fullProfileImageUrl.isNotEmpty
              ? NetworkImage(profile.fullProfileImageUrl)
              : null,
          child: profile == null || profile.fullProfileImageUrl.isEmpty
              ? const Icon(
          Icons.person,
          color: Colors.white,
          size: 40,
        )
              : null,
        ),
          accountName: Text(
          profile?.fullName ?? 'Provider Portal',
          style: appStyle(
            18,
            Colors.white,
            FontWeight.bold,
          ),
        ),
          accountEmail: Text(
          profile?.spProfile.emailAddress ?? '',
          style: appStyle(
            12,
            Colors.white70,
            FontWeight.normal,
          ),
        ),
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
                  context.push('/sp_completed_service/');
                },
              ),
              _buildDrawerTile(
                icon: Icons.build_circle_outlined,
                title: 'My Linked Services',
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/provider_linked_services',
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
    SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
        ),
        label: const Text(
          "Logout",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.redAccent.withOpacity(.35),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.pop(context); // Close drawer
          _confirmLogout(context);
        },
      ),
    ),
    const SizedBox(height: 16),
    Text(
      "v1.0.0",
      style: appStyle(
        10,
        Colors.white24,
        FontWeight.normal,
      ),
    ),
        ],
      ),
    ),
    ],
      ),
    ),
    
              body: PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: tabNotifier.setIndex,
      children: _pages,
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