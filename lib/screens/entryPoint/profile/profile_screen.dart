import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_application_2/common/controller/sp_contollers/provider_active_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_logout_controller.dart';

import 'package:flutter_application_2/common/controller/sp_contollers/provider_profile_update_controller.dart';

import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/common/widgets/help_bottom_sheet.dart';
import 'package:flutter_application_2/common/widgets/shimmers/sp_profile_skeleton.dart';
import 'package:flutter_application_2/screens/accounts_and_security/views/account_security_screen.dart';
// import 'package:flutter_application_2/screens/auth/views/profile_photo_capture/profile_photo_capture_screen.dart';
import 'package:flutter_application_2/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_2/screens/entryPoint/profile/provider_profile_photo_viewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SpProfileScreen extends StatefulWidget {
  const SpProfileScreen({super.key});

  @override
  State<SpProfileScreen> createState() => _SpProfileScreenState();
}

class _SpProfileScreenState extends State<SpProfileScreen> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  Future<void> _changeProfilePicture(SpProfileCtrl profileCtrl) async {
  try {
    final File? capturedPhoto = await _captureAndConfirmPhoto();

    if (capturedPhoto == null) return;

    final providerCtrl = Provider.of<ProviderProfileController>(
      context,
      listen: false,
    );

    final success = await providerCtrl.updateProfile(
      profileImage: capturedPhoto,
    );

    if (!mounted) return;

    if (success) {
      await profileCtrl.fetchSPByEmail();
      FlushbarService.success(
        context,
        "Profile picture updated successfully.",
      );
    } else {
      FlushbarService.error(
        context,
        providerCtrl.errorMessage ?? "Failed to update profile picture.",
      );
    }
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrint(s.toString());

    FlushbarService.error(context, e.toString());
  }
}

/// Opens the camera, lets the user preview + confirm/retake, and returns
/// the confirmed File, or null if they backed out at any point.
Future<File?> _captureAndConfirmPhoto() async {
  final ImagePicker picker = ImagePicker();
  final XFile? captured = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
    imageQuality: 85,
  );

  if (captured == null) return null; // user backed out of camera

  final File capturedFile = File(captured.path);
  final bool? confirmed = await _showPhotoConfirmationDialog(capturedFile);

  if (confirmed == true) {
    return capturedFile;
  } else if (confirmed == false) {
    // Retake
    return _captureAndConfirmPhoto();
  }
  return null; // dialog dismissed without a choice
}

Future<bool?> _showPhotoConfirmationDialog(File imageFile) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Use this photo?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  imageFile,
                  height: 250.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Retake",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Kolors.kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Use Photo"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // Generic single-field edit dialog. For "Bio" this saves via
  // ProviderProfileController; every other field (used inside the
  // Account & Security sheet) is currently just a stub.
  Future<void> _editField(String fieldName, String currentValue, {SpProfileCtrl? profileCtrl}) async {
    final lower = fieldName.toLowerCase();
    final controller = TextEditingController(text: currentValue);
    final isBioField = lower == 'bio';

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Edit $fieldName',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          keyboardType: lower == 'phone' || lower == 'mobile number'
              ? TextInputType.phone
              : lower == 'email'
                  ? TextInputType.emailAddress
                  : TextInputType.text,
          obscureText: lower.contains('password'),
          maxLines: isBioField ? 4 : 1,
          decoration: InputDecoration(
            hintText: 'Enter $fieldName',
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (isBioField) {
                final providerCtrl = Provider.of<ProviderProfileController>(context, listen: false);
                final success = await providerCtrl.updateProfile(description: controller.text);

                if (!mounted) return;

                if (success) {
                  await profileCtrl?.fetchSPByEmail();

                  if (!mounted) return;

                  FlushbarService.success(
                    context,
                    "Bio updated successfully.",
                  );
                } else {
                  if (!mounted) return;

                  FlushbarService.error(
                    context,
                    providerCtrl.errorMessage ?? "Failed to update bio.",
                  );
                }
              } else {
                // TODO: hook up phone / email / password updates to their own API calls.
                debugPrint('$fieldName updated to: ${controller.text}');
                if (mounted) setState(() {});
              }
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

  
  

  Future<void> _logout() async {
  final logoutController =
      context.read<ProviderLogoutController>();

  final success = await logoutController.logout();

  if (!mounted) return;

  if (success) {
    ProviderActiveController.instance.reset();
    Provider.of<TabIndexNotifier>(context, listen: false).reset();

    context.go('/login');

    debugPrint(
      "Service Provider logged out successfully",
    );
  } else {
    FlushbarService.error(
      context,
      logoutController.errorMessage ??
          "Logout failed. Please try again.",
    );
  }
}

  Future<void> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 50, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 14),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Kolors.kPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Kolors.kOffWhite, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
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
  super.build(context);
  final ctrl = context.watch<SpProfileCtrl>();

  return Scaffold(
    backgroundColor: Colors.black,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Kolors.kPrimary,
            Color(0xFF1A1A1A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Builder(
        builder: (_) {
          // Only show the skeleton on the true first load — pull-to-refresh
          // and any background refresh already have a cached profile, so
          // the content stays up and RefreshIndicator's own spinner is
          // what the user sees instead.
          if (ctrl.isLoading && ctrl.spProfile == null) {
            return const SpProfileSkeleton();
          }

          if (ctrl.errorMessage != null && ctrl.spProfile == null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          ctrl.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
          final sp = ctrl.spProfile;

          if (sp == null) {
            return const Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.person_off_outlined,
        color: Colors.white,
        size: 48,
      ),
      SizedBox(height: 12),
      Text(
        "No profile available.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    ],
  ),
);
          }

          return SafeArea(
            child: RefreshIndicator(
              
              onRefresh: () async {
                await context.read<SpProfileCtrl>().refresh();
              },
              child: SingleChildScrollView(
               
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- Profile Picture Section (face-detected capture only) ---
                      Consumer<ProviderProfileController>(
                        builder: (context, providerCtrl, _) {
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                      onTap: () {
                        Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProviderProfilePhotoViewer(
                        imageUrl: sp.fullProfileImageUrl,
                        profileCtrl: ctrl,
                      ),
                    ),
                        );
                      },
                      child: Container(
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
                          ) as ImageProvider,
                        ),
                      ),
                    ),
                              GestureDetector(
                                onTap: providerCtrl.isLoading ? null : () => _changeProfilePicture(ctrl),
                                child: CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: Kolors.kPrimary,
                                  child: Icon(Icons.camera_alt, size: 16.sp, color: Kolors.kSecondaryLight),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        sp.fullName,
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        sp.spProfile.emailAddress ?? '',
                        style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                      ),
                      SizedBox(height: 24.h),
                    
                      // --- Stats Card ---
                      _buildGlassCard(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Rating', ctrl.formattedRating, icon: Icons.star),
                            _buildStatItem('Location', sp.liveLocation?.suburb ?? "Location unavailable"),
                          ],
                        ),
                      ),
                    
                      SizedBox(height: 12.h),
                    
                      // --- Details Section: Name / Gender / DOB view-only, Bio editable ---
                      _buildGlassCard(
                        child: Column(
                          children: [
                         
                            _buildEditableRow(AntDesign.man, 'Gender', sp.gender, editable: false),
                            _buildEditableRow(AntDesign.calendar, 'DOB', ctrl.formattedDob, editable: false),
                            _buildEditableRow(
                              AntDesign.infocirlce,
                              'Bio',
                              sp.spDescription,
                              isBio: true,
                              editable: true,
                              isLast: true,
                              onEdit: () => _editField('Bio', sp.spDescription, profileCtrl: ctrl),
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
                          context.push('/provider_linked_services');
                        },
                      ),
                      _buildActionItem(
                      icon: MaterialCommunityIcons.shield_account_outline,
                      label: "Account & Security",
                      iconColor: Colors.tealAccent,
                      onTap: () {
                        Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountSecurityScreen(
                        phone: sp.spProfile.mobileNumber ?? '',
                        email: sp.spProfile.emailAddress ?? '',
                      ),
                    ),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return RepaintBoundary(
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
    );
  }

  Widget _buildStatItem(String label, String value, {IconData? icon}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: Colors.amber, size: 16.sp),
            if (icon != null) SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.white60)),
      ],
    );
  }

  /// A single detail row. Pass `editable: false` to render it as view-only
  /// (no pencil icon, no tap action) — used for Name, Gender, and DOB.
  Widget _buildEditableRow(
    IconData icon,
    String title,
    String value, {
    bool isBio = false,
    bool editable = false,
    bool isLast = false,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: isLast ? 0 : 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp, color: Colors.white70),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.white54)),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500),
                  maxLines: isBio ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (editable)
            IconButton(
              onPressed: onEdit ?? () => _editField(title, value),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          leading: Icon(icon, color: iconColor ?? Colors.white, size: 22.sp),
          title: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        ),
      ),
    );
  }

}