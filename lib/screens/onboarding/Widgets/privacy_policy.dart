import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Matching your dark gradient bottom
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Kolors.kOffWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Kolors.kOffWhite, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(color: Colors.white24, height: 40),
            _buildSection("1. INFORMATION WE COLLECT", 
              "We may collect the following information:\n\n"
              "• Name\n"
              "• Email address\n"
              "• Phone number\n"
              "• Profile photos\n"
              "• Service information\n"
              "• Device information\n"
              "• Location data"),
            _buildSection("2. HOW WE USE YOUR INFORMATION", 
              "We use your data to:\n\n"
              "• Create and manage your provider profile\n"
              "• Connect you with clients\n"
              "• Process bookings\n"
              "• Improve the platform\n"
              "• Ensure safety and fraud prevention"),
            _buildSection("3. LOCATION DATA", 
              "If you enable location services, Plug may access your location to help clients find providers nearby.\n\n"
              "Location data is only used while the app is active."),
            _buildSection("4. DATA SECURITY", 
              "We use industry standard security measures to protect your data. However, no system is completely secure."),
            _buildSection("5. DATA SHARING", 
              "We do not sell your personal information. Information may be shared with clients only when necessary for a service booking."),
            _buildSection("6. DATA RETENTION", 
              "Your information is stored while your account remains active. You may request deletion of your account at any time."),
            _buildSection("7. CONTACT", 
              "For privacy questions or data requests contact:\n\n"
              "t.p.tshabalala98@gmail.com"),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PLUG PRIVACY POLICY",
          style: TextStyle(
            color: Kolors.kPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Last Updated: 2026",
          style: TextStyle(color: Kolors.kOffWhite.withOpacity(0.5), fontSize: 14),
        ),
        const SizedBox(height: 20),
        const Text(
          "Plug respects your privacy and is committed to protecting your personal information.",
          style: TextStyle(color: Kolors.kOffWhite, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Kolors.kOffWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Kolors.kOffWhite.withOpacity(0.7),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}