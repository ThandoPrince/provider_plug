import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/custom_app_bar.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AccountSecurityScreen extends StatelessWidget {
  final String phone;
  final String email;

  const AccountSecurityScreen({
    super.key,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       extendBodyBehindAppBar: true,
      appBar: const CustomScreenAppBar(
  title: 'Account & Security',
   backgroundColor: Colors.transparent,
        
),
      body: SizedBox.expand(
        child: Container(
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
          child: SafeArea(
  child: Padding(
    padding: EdgeInsets.all(20.w),
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildGlassCard(
                  child: Column(
                    children: [
                      _buildTile(
                        icon: AntDesign.phone,
                        title: "Mobile Number",
                        subtitle: phone.isEmpty ? "Not set" : phone,
                        onTap: () {},
                      ),
                      Divider(color: Colors.white.withOpacity(.08)),
                      _buildTile(
                        icon: AntDesign.mail,
                        title: "Email Address",
                        subtitle: email,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                _buildGlassCard(
                  child: _buildTile(
                    icon: Feather.lock,
                    title: "Change Password",
                    subtitle: "Update your account password",
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        _buildGlassCard(
          child: _buildTile(
            icon: MaterialCommunityIcons.delete_outline,
            iconColor: Colors.redAccent,
            title: "Delete Account",
            titleColor: Colors.redAccent,
            subtitle: "Permanently remove your account and data.",
            subtitleColor: Colors.redAccent.withOpacity(.8),
            onTap: () => _confirmDeleteAccount(context),
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

  Widget _buildGlassCard({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Colors.white.withOpacity(.1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    Color titleColor = Colors.white,
    Color subtitleColor = Colors.white60,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 6.h,
      ),
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor,
        size: 22.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: subtitleColor,
          fontSize: 13.sp,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white30,
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 26,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  size: 55,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "This action cannot be undone. All your data will be permanently removed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text("Delete"),
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
      FlushbarService.info(
        context,
        "Account deletion API not implemented yet.",
      );
    }
  }
}