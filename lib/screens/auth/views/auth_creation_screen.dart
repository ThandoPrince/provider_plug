import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/registration/login_creation_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthCreationScreen extends StatefulWidget {
  const AuthCreationScreen({super.key});

  @override
  State<AuthCreationScreen> createState() => _AuthCreationScreenState();
}

class _AuthCreationScreenState extends State<AuthCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final registerCtrl = context.watch<LoginCreationController>();

    return Scaffold(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),

                  // --- Back Button ---
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Ionicons.chevron_back,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // --- Header ---
                  Text(
                    "Join the Network",
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "Create your provider account to start earning.",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // --- Email Field ---
                  _buildLabel("EMAIL ADDRESS"),
                  _buildTextField(
                    controller: _emailCtrl,
                    hint: "expert@provider.com",
                    icon: Feather.mail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty ? "Email is required" : null,
                  ),

                  SizedBox(height: 20.h),

                  // --- Mobile Field ---
                  _buildLabel("MOBILE NUMBER"),
                  _buildTextField(
                    controller: _mobileCtrl,
                    hint: "071 950 3706",
                    icon: Feather.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.isEmpty ? "Mobile number required" : null,
                  ),

                  SizedBox(height: 20.h),

                  // --- Password Field ---
                  _buildLabel("SECURE PASSWORD"),
                  _buildTextField(
                    controller: _passwordCtrl,
                    hint: "••••••••",
                    icon: Feather.lock,
                    obscureText: _obscureText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Feather.eye_off : Feather.eye,
                        color: Colors.white38,
                        size: 20.sp,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? "Minimum 6 characters" : null,
                  ),

                  SizedBox(height: 40.h),

                 
                  if (registerCtrl.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                registerCtrl.errorMessage!,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Kolors.kPrimary,
                        foregroundColor: Kolors.kOffWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: registerCtrl.isLoading
                          ? null
                          : () async {
                              final form = _formKey.currentState;
                              if (form == null || !form.validate()) return;
                              HapticFeedback.mediumImpact();

                              final success = await registerCtrl.register(
                                email: _emailCtrl.text.trim(),
                                password: _passwordCtrl.text.trim(),
                                mobileNumber: _mobileCtrl.text.trim(),
                              );

                              if (success && mounted) {
                                context.go('/sp_patch/${_emailCtrl.text.trim()}');
                              }
                            },
                      child: registerCtrl.isLoading
                          ? const CircularProgressIndicator(
                              color: Kolors.kPrimary,
                            )
                          : Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                 
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14.sp,
                          ),
                          children: const [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      onChanged: (val) {
      
      if (context.read<LoginCreationController>().errorMessage != null) {
        
      }
    },
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white24, fontSize: 15.sp),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20.sp),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
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
      ),
    );
  }
}
