import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/models/models/client_models/clients_details_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ClientInfoTile extends StatelessWidget {
  final ClientModel? client;

  const ClientInfoTile({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    if (client == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        
        color: const Color(0xFF252525), 
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        // Cleaning up the ExpansionTile defaults
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          unselectedWidgetColor: Colors.white54, // Color of the arrow
          colorScheme: const ColorScheme.dark(primary: Colors.white),
        ),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            if (expanded) HapticFeedback.lightImpact();
          },
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          
          // --- Leading: Premium Avatar ---
          leading: Hero(
            tag: 'client_avatar_${client!.fullName}',
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Kolors.kPrimary, Colors.blueAccent],
                ),
              ),
              child: CircleAvatar(
                radius: 26.r,
                backgroundColor: const Color(0xFF1A1A1A),
                backgroundImage: client!.profileImageUrl != null
                    ? NetworkImage(client!.profileImageUrl!)
                    : null,
                child: client!.profileImageUrl == null
                    ? Icon(Feather.user, color: Colors.white, size: 20.sp)
                    : null,
              ),
            ),
          ),

          // --- Title: Bold & Clean ---
          title: Text(
            client!.fullName.isNotEmpty ? client!.fullName : "Client Details",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17.sp,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          // --- Subtitle: Rating & Status ---
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Row(
              children: [
                Icon(Ionicons.star, color: Colors.amber, size: 14.sp),
                SizedBox(width: 4.w),
                Text(
                  client!.rating ?? '5.0',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    "VERIFIED CLIENT",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          children: [
            Divider(color: Colors.white.withOpacity(0.05), thickness: 1),
            SizedBox(height: 15.h),

            // --- Contact Row ---
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: "MESSAGE",
                    icon: Feather.message_square,
                    color: Colors.white.withOpacity(0.05),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      // Logic for chat
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    label: "CALL CLIENT",
                    icon: Feather.phone_call,
                    color: Kolors.kPrimary,
                    isPrimary: true,
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      // Logic for call
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the Action Buttons
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.r),
          border: isPrimary ? null : Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}