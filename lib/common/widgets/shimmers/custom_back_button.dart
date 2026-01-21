import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const CustomBackButton({Key? key, this.color, this.onPressed}) : super(key: key);

  void _handleBack(BuildContext context) {
    final goRouter = GoRouter.of(context);

    // This checks if it's safe to pop in a declarative context
    final didPop = Navigator.of(context).maybePop(); // returns Future<bool>

    didPop.then((wasPopped) {
      if (!wasPopped) {
        // If nothing was popped, fall back to a defined route
        goRouter.go('/entryPoint');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color ?? Colors.white),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => _handleBack(context),
    );
  }
}
