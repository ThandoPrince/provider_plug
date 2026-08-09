import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/provider_profile_update_controller.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/auth/views/profile_photo_capture/profile_photo_capture_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProviderProfilePhotoViewer extends StatelessWidget {
  final String imageUrl;
  final SpProfileCtrl profileCtrl;

  const ProviderProfilePhotoViewer({
    super.key,
    required this.imageUrl,
    required this.profileCtrl,
  });

Future<void> _changePicture(
  BuildContext context,
  ProviderProfileController providerCtrl,
) async {
  final File? capturedPhoto = await _captureAndConfirmPhoto(context);

  if (capturedPhoto == null) return;

  final success = await providerCtrl.updateProfile(
    profileImage: capturedPhoto,
  );

  if (!context.mounted) return;

  if (success) {
    // Refresh the profile that owns the viewer.
    await profileCtrl.fetchSPByEmail();

    if (!context.mounted) return;

    FlushbarService.success(
      context,
      "Profile picture updated successfully.",
    );

    
    Navigator.of(context).pop();
  } else {
    FlushbarService.error(
      context,
      providerCtrl.errorMessage ??
          "Failed to update profile picture.",
    );
  }
}

/// Opens the camera, lets the user preview + confirm/retake, and returns
/// the confirmed File, or null if they backed out at any point.
Future<File?> _captureAndConfirmPhoto(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? captured = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
    imageQuality: 85,
  );

  if (captured == null) return null; // user backed out of camera

  final File capturedFile = File(captured.path);

  if (!context.mounted) return null;

  final bool? confirmed = await _showPhotoConfirmationDialog(context, capturedFile);

  if (confirmed == true) {
    return capturedFile;
  } else if (confirmed == false) {
    if (!context.mounted) return null;
    return _captureAndConfirmPhoto(context); // Retake
  }
  return null; // dialog dismissed without a choice
}

Future<bool?> _showPhotoConfirmationDialog(BuildContext context, File imageFile) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderProfileController>(
      builder: (context, providerCtrl, _) {
        return MultiProvider(
          providers: [
    ChangeNotifierProvider(
      create: (_) => SpProfileCtrl()..fetchSPByEmail(),
    ),
    ChangeNotifierProvider(
      create: (_) => ProviderProfileController(),
    ),
  ],
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
            ),
            body: Stack(
              children: [
          
                Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: imageUrl.isNotEmpty
                        ? Image.network(imageUrl)
                        : Image.asset(
                            "assets/default_profile.png",
                          ),
                  ),
                ),
          
                Positioned(
                  right: 24,
                  bottom: 40,
                  child: FloatingActionButton(
                    backgroundColor: Kolors.kPrimary,
                    onPressed: providerCtrl.isLoading
                        ? null
                        : () => _changePicture(
                              context,
                              providerCtrl,
                            ),
                    child: providerCtrl.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}