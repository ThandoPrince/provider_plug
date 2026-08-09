import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/completed_services_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_2/common/widgets/shimmers/provider_ratings_skeleton.dart';
import 'package:flutter_application_2/screens/completed_services/completed_service_details/views/completed_service_details_screen.dart'; // Ensure this path is correct
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProviderRatingsScreen extends StatefulWidget {
  

  const ProviderRatingsScreen({
    Key? key,
    
  }) : super(key: key);

  @override
  State<ProviderRatingsScreen> createState() => _ProviderRatingsScreenState();
}

class _ProviderRatingsScreenState extends State<ProviderRatingsScreen> {
  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    final controller = context.read<ProviderRatingsController>();

    if (controller.ratings.isEmpty) {
      controller.fetchRatings();
    }
  });
}





  @override
  Widget build(BuildContext context) {
   return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    title: Text(
      'COMPLETED SERVICES',
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
    scrolledUnderElevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  body: Container(
    width: double.infinity,
    height: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Kolors.kPrimary,
          Color(0xFF0D0D0D),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    child: SafeArea(
       child: Consumer<ProviderRatingsController>(
        builder: (context, controller, child) {
          // Only show the skeleton on the true first load — pull-to-refresh
          // and any background refetch already have cached ratings, so the
          // list stays up and RefreshIndicator's own spinner is what shows.
          if (controller.isLoading && controller.ratings.isEmpty) {
            return const ProviderRatingsSkeleton();
          }

          if (controller.ratings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Kolors.kPrimary,
            onRefresh: controller.fetchRatings,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
              itemCount: controller.ratings.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (_, index) {
                  final rating = controller.ratings[index];
                  final client = rating.session?.shipment?.serviceOrdered?.order?.client;
                  final serviceName = rating.session?.shipment?.serviceOrdered?.order
                          ?.serviceRequired?.serviceName ??
                      "Service";
                  final status = rating.session?.sessionStatus ?? "Completed";
                  int score = int.tryParse(rating.score?.toString() ?? '0') ?? 0;
              
              
              
                  return _buildDarkGlassListItem(
                    onTap: () {
                      // RESTORED: Navigation to details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProviderRatingDetailsScreen(
                            rating: rating,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        _buildClientAvatar(client?.profileImageUrl),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      serviceName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildDarkStatusBadge(status),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                client != null
                                    ? '${client.firstName} ${client.lastName}'.trim()
                                    : 'Anonymous',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildStarRating(score),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20.sp,
                          color: Colors.white24,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
   ));
  }

  // --- DARK THEME UI COMPONENTS ---

  Widget _buildDarkGlassListItem({required Widget child, required VoidCallback onTap}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildClientAvatar(String? url) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Kolors.kPrimary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: CircleAvatar(
        radius: 26.r,
        backgroundColor: Colors.white10,
        backgroundImage: url != null ? NetworkImage(url) : null,
        child: url == null
            ? const Icon(Icons.person, color: Colors.white38)
            : null,
      ),
    );
  }

  Widget _buildStarRating(int score) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          Icons.star_rounded,
          size: 16.sp,
          color: i < score ? Colors.orangeAccent : Colors.white10,
        );
      }),
    );
  }

  Widget _buildDarkStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Kolors.kPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Kolors.kPrimary,
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 60.sp,
              color: Colors.white10,
            ),
            SizedBox(height: 16.h),
            Text(
              "No completed services yet.",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}