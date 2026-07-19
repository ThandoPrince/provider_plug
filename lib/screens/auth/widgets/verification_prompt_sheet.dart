// lib/screens/onboarding/widgets/verification_prompt_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/onboarding/Widgets/back_exit_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet shown after a provider successfully links a service,
/// prompting them to submit their verification affidavit now or later.
class VerificationPromptSheet extends StatelessWidget {
  
  final String providerServiceId;
  final String serviceId;
  final VoidCallback onContinue;

  const VerificationPromptSheet({
   
    required this.providerServiceId,
    required this.serviceId,
    required this.onContinue,
    super.key,
  });

  static final String _baseUrl = dotenv.env['MEDIA_BASE_URL']!;
  static final String affidavitTemplateUrl =
      "$_baseUrl/static/templates/PLUG_Service_Provider_Declaration_v2.pdf";

  static Future<void> show({
    required BuildContext context,
   
    required String serviceId,
    required String providerServiceId,
    required VoidCallback onContinue,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      isDismissible: false, // force an explicit choice rather than a swipe-away
      enableDrag: false,
      builder: (_) => VerificationPromptSheet(
        
        
        providerServiceId: providerServiceId,
        serviceId: serviceId,
        onContinue: onContinue,
      ),
    );
  }

  Future<void> _downloadTemplate(BuildContext context) async {
    final uri = Uri.parse(affidavitTemplateUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the affidavit template.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DoubleBackToExit(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Get Verified",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Kolors.kOffWhite,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Submit a signed affidavit to confirm your identity"
                  ".You won't receive client requests until "
                  "it's verified — you can do this now or come back to it later.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Kolors.kOffWhite.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                TextButton.icon(
                  onPressed: () => _downloadTemplate(context),
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Kolors.kPrimary,
                    size: 18,
                  ),
                  label: const Text(
                    "Download affidavit template",
                    style: TextStyle(
                      color: Kolors.kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(
                        '/providers/services/$providerServiceId/affidavit',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Kolors.kPrimary,
                      foregroundColor: Kolors.kOffWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Verify Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onContinue();
                    },
                    child: Text(
                      "Maybe later",
                      style: TextStyle(
                        color: Kolors.kOffWhite.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
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
}