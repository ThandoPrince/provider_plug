import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_2/screens/entryPoint/home/views/home_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/profile/profile_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/widgets/custom_app_bar.dart';
import 'package:flutter_application_2/screens/scheduled_services/views/scheduled_services_screen.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late final PageController _pageController;

  /// 🔒 Pages created ONCE — no refresh
  final List<Widget> _pages = const [
    HomeScreen(email: "nomfundomabunda748@gmail.com"),
    ScheduledOrdersScreen(
      email: "nomfundomabunda748@gmail.com",
    ),
    SpProfileScreen(email: "nomfundomabunda748@gmail.com"),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabIndexNotifier>(
      builder: (context, tabNotifier, _) {
        return WillPopScope(
          /// ✅ Back button → always go Home first
          onWillPop: () async {
            if (tabNotifier.index != 0) {
              tabNotifier.setIndex(0);
              _pageController.jumpToPage(0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            /// ✅ AppBar ONLY on Home
            appBar: tabNotifier.index == 0
                ? const CustomAppBar()
                : null,

            /// ☰ Drawer
            drawer: Drawer(
              backgroundColor: Kolors.kOffWhite,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration:
                        const BoxDecoration(color: Kolors.kPrimary),
                    child: Text(
                      'Provider Menu',
                      style:
                          appStyle(16, Colors.white, FontWeight.bold),
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
                    leading:
                        const Icon(Icons.build_circle_outlined),
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

            /// 🌈 Swipe-enabled body
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Kolors.kPrimary,
                    Kolors.kSecondaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: tabNotifier.setIndex,
                children: _pages,
              ),
            ),

            /// 🔻 Bottom Navigation
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Kolors.kPrimary,
              ),
              child: BottomNavigationBar(
                currentIndex: tabNotifier.index,
                onTap: (index) {
                  tabNotifier.setIndex(index);
                  _pageController.animateToPage(
                    index,
                    duration:
                        const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                },
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedItemColor: Kolors.kWhite,
                unselectedItemColor: Kolors.kDark,
                backgroundColor:
                    const Color.fromARGB(255, 134, 165, 180),
                items: [
                  BottomNavigationBarItem(
                    icon: tabNotifier.index == 0
                        ? const Icon(Ionicons.home,
                            color: Kolors.kWhite)
                        : const Icon(
                            Ionicons.home_outline),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: tabNotifier.index == 1
                        ? const Icon(
                            Icons.volunteer_activism,
                            color: Kolors.kWhite,
                          )
                        : const Icon(
                            Icons
                                .volunteer_activism_rounded,
                          ),
                    label: "Scheduled",
                  ),
                  BottomNavigationBarItem(
                    icon: tabNotifier.index == 2
                        ? const Icon(Ionicons.person,
                            color: Kolors.kWhite)
                        : const Icon(
                            Ionicons.person_outline),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
