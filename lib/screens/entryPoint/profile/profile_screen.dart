import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/sp_contollers/sp_profile_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/help_bottom_sheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
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
      print('Selected image path: ${image.path}');
    }
  }

void _editField(String fieldName, String currentValue) async {
  final lower = fieldName.toLowerCase();

  if (lower == 'dob') {
    // Parse existing DOB or fallback
    DateTime initialDate = DateTime.tryParse(currentValue) ?? DateTime(2000);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      print('DOB updated to: ${pickedDate.toIso8601String()}');
      setState(() {}); // Update UI
    }
  } else if (lower == 'gender') {
    String? selectedGender = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Male', 'Female', 'Other']
              .map((g) => RadioListTile<String>(
                    title: Text(g),
                    value: g,
                    groupValue: currentValue,
                    onChanged: (value) => Navigator.pop(context, value),
                  ))
              .toList(),
        ),
      ),
    );
    if (selectedGender != null) {
      print('Gender updated to: $selectedGender');
      setState(() {}); // Update UI
    }
  } else {
    final controller = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          keyboardType: lower == 'phone' ? TextInputType.phone : TextInputType.text,
          maxLines: lower == 'description' ? 5 : 1,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              print('$fieldName updated to: ${controller.text}');
              Navigator.pop(context);
              setState(() {}); // Update UI
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}


  void _logout() {
    print("Service Provider logged out!");
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return ChangeNotifierProvider(
      create: (_) => SpProfileCtrl()..fetchSPByEmail(widget.email),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Consumer<SpProfileCtrl>(
            builder: (context, ctrl, child) {
              if (ctrl.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (ctrl.errorMessage != null) {
                return Center(
                  child: Text(
                    ctrl.errorMessage!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                );
              }

              final sp = ctrl.spProfile;
              if (sp == null) {
                return const Center(
                    child: Text(
                  'No service provider profile available.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ));
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile picture
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 65.r,
                            backgroundImage: sp.fullProfileImageUrl.isNotEmpty
                                ? NetworkImage(sp.fullProfileImageUrl)
                                : const AssetImage(
                                        'assets/default_profile.png')
                                    as ImageProvider,
                          ),
                          GestureDetector(
                            onTap: _changeProfilePicture,
                            child: CircleAvatar(
                              radius: 18.r,
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.edit,
                                  size: 18.sp, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Main info card
                      _buildGlassCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditableRow('Full Name', sp.fullName),
                            _buildEditableRow('Email', sp.spProfile.emailAddress),
                            _buildEditableRow('Phone', sp.mobileNumber),
                            _buildEditableRow('Gender', sp.gender),
                            _buildEditableRow('DOB', ctrl.formattedDob),
                            _buildEditableRow('Description', sp.spDescription,
                                isBio: true),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Stats card
                      _buildGlassCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                                'Services', sp.services.length.toString()),
                            _buildStatItem('Rating', ctrl.formattedRating),
                            _buildStatItem(
                                'Location', sp.location?.locality ?? "N/A"),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // View Services card
                      _buildGlassCard(
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(20.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    "View My Services",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_right,
                                    color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Help center
                      _buildGlassCard(
                        child: InkWell(
                          onTap: () => showHelpCenterBottomSheet(context),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  MaterialCommunityIcons.lifebuoy,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "Help & Support",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                const Icon(Icons.keyboard_arrow_right,
                                    color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Logout card
                      _buildGlassCard(
                        child: InkWell(
                          onTap: _logout,
                          borderRadius: BorderRadius.circular(20.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  MaterialCommunityIcons.logout,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  // Editable row helper (mini editor for bio + tappable icons)
Widget _buildEditableRow(String title, String value, {bool isBio = false}) {
  final displayText = isBio && value.length > 50
      ? '${value.substring(0, 50)}...'
      : value;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _editField(title, value),
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // Stat item helper
  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 4.h),
        Text(label,
            style: TextStyle(fontSize: 14.sp, color: Colors.black.withOpacity(0.7)),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // Glass card helper
  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: child,
          ),
        ),
      ),
    );
  }
}
