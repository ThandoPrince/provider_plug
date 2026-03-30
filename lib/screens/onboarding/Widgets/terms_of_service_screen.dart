import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:go_router/go_router.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Terms of Service",
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
            _buildSection("1. PLATFORM ROLE", 
              "Plug is a technology platform that connects clients with independent service providers. "
              "Plug does not employ service providers. You operate as an independent contractor."),
            _buildSection("2. PROVIDER RESPONSIBILITIES", 
              "Service providers must:\n\n"
              "• Provide accurate profile information\n"
              "• Deliver services professionally and safely\n"
              "• Honor confirmed bookings\n"
              "• Communicate respectfully with clients\n"
              "• Follow local laws and regulations\n\n"
              "Providers are responsible for the quality and legality of their services."),
            _buildSection("3. BOOKINGS AND PAYMENTS", 
              "When a client accepts your offer:\n\n"
              "• The booking becomes binding.\n"
              "• The provider must deliver the agreed service.\n"
              "• Payments may be processed through Plug or directly with the client depending on service configuration.\n\n"
              "Plug may charge a service fee in future updates."),
            _buildSection("4. LOCATION SERVICES", 
              "Plug may access your device location to:\n\n"
              "• Match you with nearby clients\n"
              "• Track service arrival\n"
              "• Improve job discovery\n\n"
              "Location data is used only for platform functionality."),
            _buildSection("5. ACCOUNT SUSPENSION", 
              "Plug may suspend or terminate provider accounts for:\n\n"
              "• Fraud or Misconduct\n"
              "• Repeated cancellations\n"
              "• Unsafe or illegal services\n"
              "• Violation of these terms"),
            _buildSection("6. LIMITATION OF LIABILITY", 
              "Plug is not liable for disputes between providers and clients. Providers agree to resolve service issues professionally."),
            _buildSection("7. CHANGES TO TERMS", 
              "Plug may update these terms periodically. Continued use of the platform means you accept the updated terms."),
            const SizedBox(height: 20),
            _buildTerminationNote(),
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
          "SERVICE PROVIDER TERMS",
          style: TextStyle(
            color: Kolors.kPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Last Updated: 2026",
          style: TextStyle(color: Kolors.kOffWhite.withOpacity(0.5), fontSize: 14),
        ),
        const SizedBox(height: 20),
        const Text(
          "Welcome to Plug. These Terms of Service govern your use of the Plug platform as a service provider.",
          style: TextStyle(color: Kolors.kOffWhite, fontSize: 15, height: 1.5),
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

  Widget _buildTerminationNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: const Text(
        "If you do not agree with these terms, you must discontinue use of the platform immediately.",
        style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}