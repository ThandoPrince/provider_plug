import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching a rating list item on ProviderRatingsScreen —
/// avatar, service name + status badge, client name, star row.
/// Shown only on the very first load (no cached ratings yet).
class ProviderRatingsSkeleton extends StatelessWidget {
  const ProviderRatingsSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.08),
      highlightColor: Colors.white.withOpacity(0.20),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (_, __) => _buildListItemSkeleton(),
      ),
    );
  }

  Widget _buildListItemSkeleton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 60.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Container(width: 100.w, height: 12.sp, color: Colors.white),
                    SizedBox(height: 10.h),
                    _buildStarRowSkeleton(),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right, size: 20.sp, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRowSkeleton() {
    return Row(
      children: List.generate(
        5,
        (i) => Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: Icon(Icons.star_rounded, size: 16.sp, color: Colors.white),
        ),
      ),
    );
  }
}