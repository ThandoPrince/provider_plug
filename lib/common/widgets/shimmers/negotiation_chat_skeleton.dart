import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton shown only on the very first load of a negotiation thread.
/// Mimics the chat layout (alternating bubbles + input bar) so there's
/// no layout jump once real messages arrive.
class NegotiationChatSkeleton extends StatelessWidget {
  const NegotiationChatSkeleton({super.key, this.bubbleCount = 6});

  final int bubbleCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.10),
            highlightColor: Colors.white.withOpacity(0.22),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: bubbleCount,
              itemBuilder: (context, index) => _buildBubbleSkeleton(index),
            ),
          ),
        ),
        _buildInputAreaSkeleton(),
      ],
    );
  }

  Widget _buildBubbleSkeleton(int index) {
    final isProvider = index.isOdd;
    final widths = [150.0, 210.0, 180.0];
    final bubbleWidth = widths[index % widths.length];

    return Align(
      alignment: isProvider ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        width: bubbleWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isProvider ? 16 : 4),
            bottomRight: Radius.circular(isProvider ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: bubbleWidth - 24,
              height: 13,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: (bubbleWidth - 24) * 0.55,
              height: 11,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAreaSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.10),
        highlightColor: Colors.white.withOpacity(0.22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 90,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}