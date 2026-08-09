import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching the shape of a rating ListTile inside the
/// "Reviews" ExpansionTile on ClientDetailsScreen.
class ClientRatingsSkeleton extends StatelessWidget {
  const ClientRatingsSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.10),
      highlightColor: Colors.white.withOpacity(0.25),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => _buildRatingRowSkeleton(),
        ),
      ),
    );
  }

  Widget _buildRatingRowSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 80, height: 11, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}