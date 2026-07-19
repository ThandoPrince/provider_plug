import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

import 'package:flutter_application_2/screens/entryPoint/widgets/location_widget.dart';
import 'package:flutter_application_2/screens/entryPoint/widgets/notifications_widget.dart';
import 'package:flutter_application_2/screens/entryPoint/widgets/settings_widget.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionController>();
    

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,

      leadingWidth: 100, // increase width to fit both icons

      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),

      title: const Text(
        "Provider",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      actions: const [ProviderActiveToggle()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
