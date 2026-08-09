import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching a service row in SelectAServiceScreen —
/// title line, risk badge, and a trailing radio icon.
class SelectServiceSkeleton extends StatelessWidget {
  const SelectServiceSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.5),
      highlightColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (_, __) => _buildRowSkeleton(),
      ),
    );
  }

  Widget _buildRowSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 160, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}