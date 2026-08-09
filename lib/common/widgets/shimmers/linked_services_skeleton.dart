import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching the shape of a linked-service card in
/// ProviderLinkedServicesScreen — used only on the very first load.
class LinkedServicesSkeleton extends StatelessWidget {
  const LinkedServicesSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.10),
      highlightColor: Colors.white.withOpacity(0.22),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildServiceCardSkeleton(),
      ),
    );
  }

  Widget _buildServiceCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 100, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 1, color: Colors.white),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItemSkeleton(),
              _buildInfoItemSkeleton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemSkeleton() {
    return Expanded(
      child: Row(
        children: [
          Container(
            height: 16,
            width: 16,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 50, height: 10, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 70, height: 13, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}