import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/registration/profile_creation_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/auth/views/profile_photo_capture/profile_photo_capture_screen.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/back_exit_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml for date formatting

class SPProfilePatchScreen extends StatefulWidget {
 
  const SPProfilePatchScreen({super.key});

  @override
  State<SPProfilePatchScreen> createState() => _SPProfilePatchScreenState();
}

class _SPProfilePatchScreenState extends State<SPProfilePatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _idNumberCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String? _selectedGender;
  File? _profileImage;
 

  final List<String> _genderOptions = [
    "Male",
    "Female",
    "Other",
    "Prefer not to say",
  ];



  
  @override
  Widget build(BuildContext context) {
    final spCtrl = context.watch<SPProfileCreationController>();

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: Kolors.kPrimary,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                      vertical: 10.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Profile Image Picker ---
                          Center(child: _buildImagePicker()),
                          SizedBox(height: 30.h),
      
                          _buildLabel("LEGAL FULL NAME"),
                          _buildTextField(
                            _fullNameCtrl,
                            "e.g. John Doe",
                            Feather.user,
                          ),
      
                          SizedBox(height: 20.h),
      
                          _buildLabel("GENDER"),
                          _buildGenderDropdown(),
      
                          SizedBox(height: 20.h),
      
                          _buildLabel("NATIONAL ID NUMBER"),
                          _buildTextField(
                            _idNumberCtrl,
                            "13-Digit ID Number",
                            Feather.shield,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                          ),
      
                          SizedBox(height: 20.h),
      
                          _buildLabel("DATE OF BIRTH"),
                          _buildDatePickerField(),
      
                          SizedBox(height: 20.h),
      
                          _buildLabel("PROFESSIONAL DESCRIPTION"),
                          _buildTextField(
                            _descCtrl,
                            "Tell clients about your expertise...",
                            Feather.edit_3,
                            maxLines: 4,
                          ),
      
                          SizedBox(height: 40.h),
      
                          // --- Save Button ---
                          _buildSaveButton(spCtrl),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper: Custom AppBar ---
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Feather.chevron_left, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "Profile Setup",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  

  // --- Helper: Gender Dropdown ---
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      dropdownColor: const Color(0xFF252525),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Feather.chevron_down, color: Colors.white54),
      decoration: _inputDecoration(Feather.users, "Select Gender"),
      items: _genderOptions.map((String gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (val) => setState(() => _selectedGender = val),
      validator: (val) => val == null ? "Gender is required" : null,
    );
  }

  // --- Helper: Date Picker ---
  Widget _buildDatePickerField() {
    return TextFormField(
      controller: _dobCtrl,
      readOnly: true,
      onTap: _selectDate,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(Feather.calendar, "YYYY-MM-DD"),
      validator: (val) => val!.isEmpty ? "Birth date is required" : null,
    );
  }
Widget _buildImagePicker() {
  return Stack(
    alignment: Alignment.bottomRight,
    children: [
      Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Kolors.kPrimary],
          ),
        ),
        child: CircleAvatar(
          radius: 60.r,
          backgroundColor: const Color(0xFF252525),
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : null,
          child: _profileImage == null
              ? Icon(Feather.camera, size: 35.sp, color: Colors.white24)
              : null,
        ),
      ),
      GestureDetector(
        onTap: _captureProfilePhoto,
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Feather.plus, size: 18.sp, color: Kolors.kPrimary),
        ),
      ),
    ],
  );
}

Future<void> _captureProfilePhoto() async {
  final result = await Navigator.push<File>(
    context,
    MaterialPageRoute(builder: (_) => const ProfilePhotoCaptureScreen()),
  );

  if (result != null && mounted) {
    setState(() => _profileImage = result);
  }
}
  // --- Helper: Label Style ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // --- Helper: Reusable TextField ---
  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: _inputDecoration(icon, hint),
      validator: (val) => val!.isEmpty ? "This field is required" : null,
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white24, fontSize: 14.sp),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20.sp),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  // --- Helper: Button ---
  Widget _buildSaveButton(SPProfileCreationController spCtrl) {
    return SizedBox(
      width: double.infinity,
      height: 58.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Kolors.kPrimary,
          foregroundColor: Kolors.kOffWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          elevation: 0,
        ),
        onPressed: spCtrl.isLoading ? null : _submitProfile,
        child: spCtrl.isLoading
            ? const CircularProgressIndicator(color: Kolors.kPrimary)
            : Text(
                "SAVE PROFILE",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  // --- Logic: Date Picker ---
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Kolors.kPrimary,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  

 Future<void> _submitProfile() async {
    // 1. Validate Form Fields (Name, ID, etc.)
    if (!_formKey.currentState!.validate()) return;

    // 2. Validate Profile Image (P.p)
    if (_profileImage == null) {
  HapticFeedback.vibrate();

  FlushbarService.error(
    context,
    "Please select a profile photo to continue.",
    duration: const Duration(seconds: 3),
  );

  return;
}

    HapticFeedback.heavyImpact();

    final controller = context.read<SPProfileCreationController>();
    
    final success = await controller.patchProfile(
      
      fullName: _fullNameCtrl.text.trim(),
      gender: _selectedGender!,
      idNumber: _idNumberCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      spDescription: _descCtrl.text.trim(),
      profileImage: _profileImage,
    );

    if (success && mounted) {
      context.go('/sp_address_document');
    } else if (mounted) {
  FlushbarService.error(
    context,
    controller.errorMessage ?? "An unexpected error occurred",
  );
}
  }
}
