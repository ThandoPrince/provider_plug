import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';

class CustomScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  const CustomScreenAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      centerTitle: centerTitle,
     
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      title: Text(
        title.toUpperCase(),
        style: appStyle(
          14,
          Colors.white,
          FontWeight.bold,
        ).copyWith(
          letterSpacing: 1.5,
        ),
      ),
      actions: actions,
    );
  }
}