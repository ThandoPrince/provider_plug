import 'dart:ui';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/push_notification_service.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/help_bottom_sheet.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class SpProfileScreen extends StatefulWidget {
  final String email;
  const SpProfileScreen({super.key, required this.email});

  @override
  State<SpProfileScreen> createState() => _SpProfileScreenState();
}

class _SpProfileScreenState extends State<SpProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  void _changeProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint('Selected image path: ${image.path}');
    }
  }

  void _editField(String fieldName, String currentValue) async {
    final lower = fieldName.toLowerCase();

    if (lower == 'dob') {
      DateTime initialDate = DateTime.tryParse(currentValue) ?? DateTime(2000);
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        debugPrint('DOB updated to: ${pickedDate.toIso8601String()}');
        setState(() {});
      }
    } else if (lower == 'gender') {
      String? selectedGender = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Select Gender',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Male', 'Female', 'Other']
                .map(
                  (g) => RadioListTile<String>(
                    title: Text(g),
                    value: g,
                    activeColor: Kolors.kPrimary,
                    groupValue: currentValue,
                    onChanged: (value) => Navigator.pop(context, value),
                  ),
                )
                .toList(),
          ),
        ),
      );
      if (selectedGender != null) {
        debugPrint('Gender updated to: $selectedGender');
        setState(() {});
      }
    } else {
      final controller = TextEditingController(text: currentValue);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Edit $fieldName',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: lower == 'phone'
                ? TextInputType.phone
                : TextInputType.text,
            maxLines: lower == 'description' ? 4 : 1,
            decoration: InputDecoration(
              hintText: 'Enter $fieldName',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('$fieldName updated to: ${controller.text}');
                Navigator.pop(context);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Kolors.kPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _logout() async {
  try {
    
    await AuthSessionController.instance.clearSession();
    Provider.of<TabIndexNotifier>(context, listen: false).reset();

    

 

    if (!mounted) return;

    
    context.go('/login');

    debugPrint("Service Provider logged out successfully");
  } catch (e) {
    debugPrint("Logout failed: $e");

    if (!mounted) return;
    FlushbarHelper.createError(
      message: "Logout failed. Please try again.",
    ).show(context);
  }
}

  Future<void> _confirmLogout(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 50,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 16),

              const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Kolors.kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Kolors.kOffWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );

  if (result == true) {
   _logout();
  }
}

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpProfileCtrl()..fetchSPByEmail(widget.email),
      child: Scaffold(
        backgroundColor: Colors.black, // Background for the gradient to sit on
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Consumer<SpProfileCtrl>(
            builder: (context, ctrl, child) {
              if (ctrl.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (ctrl.errorMessage != null) {
                return Center(
                  child: Text(
                    ctrl.errorMessage!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                );
              }

              final sp = ctrl.spProfile;
              if (sp == null) {
                return const Center(
                  child: Text(
                    'No profile available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Profile Picture Section ---
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 60.r,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: sp.fullProfileImageUrl.isNotEmpty
                                  ? NetworkImage(sp.fullProfileImageUrl)
                                  : const AssetImage(
                                          'assets/default_profile.png',
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          GestureDetector(
                            onTap: _changeProfilePicture,
                            child: CircleAvatar(
                              radius: 18.r,
                              backgroundColor: Kolors.kOffWhite,
                              child: Icon(
                                Icons.camera_alt,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        sp.fullName,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        sp.spProfile.emailAddress ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // --- Stats Card ---
                      _buildGlassCard(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Rating',
                              ctrl.formattedRating,
                              icon: Icons.star,
                            ),
                            _buildStatItem(
                              'Location',
                              sp.location?.locality ?? "N/A",
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // --- Details Section ---
                      _buildGlassCard(
                        child: Column(
                          children: [
                            _buildEditableRow(
                              AntDesign.user,
                              'Full Name',
                              sp.fullName,
                            ),
                            _buildEditableRow(
                              AntDesign.phone,
                              'Phone',
                              sp.spProfile.mobileNumber ?? 'N/A',
                            ),
                            _buildEditableRow(
                              AntDesign.man,
                              'Gender',
                              sp.gender,
                            ),
                            _buildEditableRow(
                              AntDesign.calendar,
                              'DOB',
                              ctrl.formattedDob,
                            ),
                            _buildEditableRow(
                              AntDesign.infocirlce,
                              'Bio',
                              sp.spDescription,
                              isBio: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // --- Action List ---
                      _buildActionItem(
                        icon: MaterialCommunityIcons.hand_heart_outline,
                        label: "View My Services",
                        onTap: () {
                          context.push(
                            '/provider_linked_services?email=${Uri.encodeComponent(widget.email)}',
                          );
                        },
                      ),
                      _buildActionItem(
                        icon: MaterialCommunityIcons.lifebuoy,
                        label: "Help & Support",
                        iconColor: Colors.blueAccent,
                        onTap: () => showHelpCenterBottomSheet(context),
                      ),
                      _buildActionItem(
                        icon: MaterialCommunityIcons.logout,
                        label: "Logout",
                        iconColor: Colors.redAccent,
                        onTap: () => _confirmLogout(context),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {IconData? icon}) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.amber, size: 16.sp),
            if (icon != null) SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildEditableRow(
    IconData icon,
    String title,
    String value, {
    bool isBio = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.white70),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, color: Colors.white54),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isBio ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editField(title, value),
            icon: Icon(Feather.edit_3, size: 16.sp, color: Kolors.kOffWhite),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: _buildGlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          leading: Icon(icon, color: iconColor ?? Colors.white, size: 22.sp),
          title: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        ),
      ),
    );
  }
}
