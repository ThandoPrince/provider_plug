import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching a qualification card in
/// ProviderServiceDetailsScreen's "Qualifications" section —
/// five label/value tiles plus a two-button row.
class QualificationsSkeleton extends StatelessWidget {
  const QualificationsSkeleton({super.key, this.itemCount = 2});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.20),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => _buildQualificationCardSkeleton(),
        ),
      ),
    );
  }

  Widget _buildQualificationCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _buildTileSkeleton(),
          _buildTileSkeleton(),
          _buildTileSkeleton(),
          _buildTileSkeleton(),
          _buildTileSkeleton(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTileSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 60, height: 10, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: double.infinity, height: 14, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}