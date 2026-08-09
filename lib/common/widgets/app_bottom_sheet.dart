import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              if (title != null) ...[
                const SizedBox(height: 18),
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              ...children,
            ],
          ),
        ),
      ),
    );
  }
}