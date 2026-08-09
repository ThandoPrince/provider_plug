import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching the 2-column image grid in
/// ProviderServiceDetailsScreen's "Service Gallery" section.
class ServiceGallerySkeleton extends StatelessWidget {
  const ServiceGallerySkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(color: Colors.white10),
        ),
      ),
    );
  }
}