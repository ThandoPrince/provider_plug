// lib/common/widgets/shimmers/booking_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A skeleton/shimmer widget that mimics the structure of the provider booking cards
/// Used as a skeletonizer while booking data is loading
class BookingSkeleton extends StatelessWidget {
  const BookingSkeleton({
    super.key,
    this.itemCount = 3,
    this.showEmptyState = false,
  });

  final int itemCount;
  final bool showEmptyState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    if (showEmptyState) {
      return _buildEmptyStateSkeleton(context, baseColor, highlightColor);
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildBookingCardSkeleton(context),
      ),
    );
  }

  Widget _buildBookingCardSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + status pill row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildSkeletonLine(
                    width: double.infinity,
                    height: 18,
                    radius: 4,
                  ),
                ),
                const SizedBox(width: 12),
                _buildSkeletonLine(width: 70, height: 24, radius: 20),
              ],
            ),

            const SizedBox(height: 18),

            // Divider
            _buildSkeletonLine(
              width: double.infinity,
              height: 1,
              radius: 0.5,
            ),

            const SizedBox(height: 18),

            // Client row
            _buildDetailRowSkeleton(labelWidth: 44),
            const SizedBox(height: 6),
            // Date & Time row
            _buildDetailRowSkeleton(labelWidth: 78),
            const SizedBox(height: 6),
            // Service row
            _buildDetailRowSkeleton(labelWidth: 54),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowSkeleton({required double labelWidth}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkeletonCircle(size: 18),
        const SizedBox(width: 8),
        _buildSkeletonLine(width: labelWidth, height: 14, radius: 4),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSkeletonLine(
            width: double.infinity,
            height: 14,
            radius: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadgeSkeleton() {
    // No longer used by the card skeleton, kept for backward compatibility.
    return _buildSkeletonLine(width: 70, height: 24, radius: 20);
  }



  Widget _buildSkeletonLine({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildSkeletonCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEmptyStateSkeleton(
    BuildContext context,
    Color baseColor,
    Color highlightColor,
  ) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildBookingCardSkeleton(context),
      ),
    );
  }
}

/// Lightweight shimmer line widget for simple skeleton lines
class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Lightweight shimmer circle widget
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Convenience widget for a single booking card skeleton
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingSkeleton(itemCount: 1);
  }
}

/// Convenience widget for a list of booking card skeletons
class BookingListSkeleton extends StatelessWidget {
  const BookingListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return BookingSkeleton(itemCount: itemCount);
  }
}

/// Convenience widget for empty state skeleton
class EmptyBookingSkeleton extends StatelessWidget {
  const EmptyBookingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return BookingSkeleton(showEmptyState: true);
  }
}