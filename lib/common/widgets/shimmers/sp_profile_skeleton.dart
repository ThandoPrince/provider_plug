import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton matching the shape of SpProfileScreen's content —
/// avatar, name/email, stats card, details card, action list.
/// Shown only on the very first load (no cached profile yet).
class SpProfileSkeleton extends StatelessWidget {
  const SpProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.10),
        highlightColor: Colors.white.withOpacity(0.22),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 128.r,
                height: 128.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: 16.h),
              // Name
              Container(width: 160.w, height: 20.h, color: Colors.white),
              SizedBox(height: 8.h),
              // Email
              Container(width: 200.w, height: 14.h, color: Colors.white),
              SizedBox(height: 24.h),

              // Stats card
              _buildCardSkeleton(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItemSkeleton(),
                    _buildStatItemSkeleton(),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Details card (Gender, DOB, Bio rows)
              _buildCardSkeleton(
                child: Column(
                  children: [
                    _buildDetailRowSkeleton(),
                    SizedBox(height: 12.h),
                    _buildDetailRowSkeleton(),
                    SizedBox(height: 12.h),
                    _buildDetailRowSkeleton(isLast: true),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Action list rows
              _buildActionRowSkeleton(),
              _buildActionRowSkeleton(),
              _buildActionRowSkeleton(),
              _buildActionRowSkeleton(isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      children: [
        Container(width: 50.w, height: 18.h, color: Colors.white),
        SizedBox(height: 6.h),
        Container(width: 40.w, height: 12.h, color: Colors.white),
      ],
    );
  }

  Widget _buildDetailRowSkeleton({bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20.sp,
          height: 20.sp,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 60.w, height: 11.h, color: Colors.white),
              SizedBox(height: 6.h),
              Container(width: double.infinity, height: 15.h, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRowSkeleton({bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: _buildCardSkeleton(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 22.sp,
                height: 22.sp,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              SizedBox(width: 16.w),
              Container(width: 140.w, height: 16.h, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}