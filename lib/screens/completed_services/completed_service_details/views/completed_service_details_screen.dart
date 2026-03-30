import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/ratings_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ProviderRatingDetailsScreen extends StatelessWidget {
  final RatingModel rating;

  const ProviderRatingDetailsScreen({
    Key? key,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shipment = rating.session?.shipment;
    final bookingItem = shipment?.serviceOrdered;
    final order = bookingItem?.order;
    final client = order?.client;
    final service = order?.serviceRequired;

    final durationSec = rating.session?.durationSeconds ?? 0;
    final durationText = "${(durationSec / 60).floor()}m ${durationSec % 60}s";

    final checkinTime = rating.session?.checkinTime != null
        ? DateFormat('dd MMM yyyy – HH:mm').format(rating.session!.checkinTime!)
        : 'N/A';

    final checkoutTime = rating.session?.checkoutTime != null
        ? DateFormat('dd MMM yyyy – HH:mm').format(rating.session!.checkoutTime!)
        : 'N/A';

    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'SERVICE RECEIPT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF0D0D0D)], // Deep charcoal transition
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                // --- TOP SUMMARY CARD ---
                _buildDarkGlassCard(
                  child: Column(
                    children: [
                      _buildProfileHeader(client?.profileImageUrl),
                      SizedBox(height: 12.h),
                      Text(
                        "${client?.firstName ?? ''} ${client?.lastName ?? ''}".trim().isEmpty
                            ? 'Unknown Client'
                            : "${client?.firstName ?? ''} ${client?.lastName ?? ''}".trim(),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        service?.serviceName?.toUpperCase() ?? 'GENERAL SERVICE',
                        style: TextStyle(
                          color: Kolors.kPrimary.withOpacity(0.8),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontSize: 11.sp,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Divider(color: Colors.white.withOpacity(0.05), thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniStat("Income", "R${order?.finalPrice ?? '0'}", Colors.greenAccent),
                          _buildMiniStat("Duration", durationText, Colors.white),
                          _buildMiniStat("Rating", "${rating.score ?? '0'}/5", Colors.orangeAccent),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // --- SERVICE LOGS ---
                _buildDarkGlassCard(
                  title: "Session Details",
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.login_rounded, "Check-in", checkinTime),
                      _buildDetailRow(Icons.logout_rounded, "Check-out", checkoutTime),
                      _buildDetailRow(
                        Icons.map_rounded,
                        "Location",
                        order?.deliveryAddress?.formattedAddress ?? 'N/A',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // --- FEEDBACK SECTION ---
                _buildDarkGlassCard(
                  title: "Client Review",
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      rating.review?.isEmpty ?? true
                          ? "The client didn't leave a written comment."
                          : "\"${rating.review!}\"",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- STYLING HELPERS ---

  Widget _buildProfileHeader(String? url) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.3), width: 2),
      ),
      child: CircleAvatar(
        radius: 45.r,
        backgroundColor: Colors.white10,
        backgroundImage: url != null ? NetworkImage(url) : null,
        child: url == null ? Icon(Icons.person, size: 40.sp, color: Colors.white24) : null,
      ),
    );
  }

  Widget _buildDarkGlassCard({required Widget child, String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
            color: valueColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white24,
            fontWeight: FontWeight.bold,
            fontSize: 9.sp,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Kolors.kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Kolors.kPrimary, size: 18.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}