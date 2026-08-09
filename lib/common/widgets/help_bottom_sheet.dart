
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showHelpCenterBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      ),
    ),
    builder: (sheetContext) {
      return Container(
        height: MediaQuery.of(sheetContext).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Kolors.kPrimary,
              Color(0xFF1A1A1A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Plug Provider App Help Center',
                  style: appStyle(
                    18.0,
                    Kolors.kOffWhite,
                    FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  'We\'re here to help! Find answers to frequently asked '
                  'questions or contact our support team.',
                  textAlign: TextAlign.center,
                  style: appStyle(
                    16.0,
                    Kolors.kOffWhite,
                    FontWeight.normal,
                  ),
                ),

                SizedBox(height: 15.h),

                // FAQs
                const Text(
                  'FAQs',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Kolors.kOffWhite,
                  ),
                ),

                const SizedBox(height: 5.0),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Can I reschedule an active booking?',
                    style: TextStyle(
                      color: Kolors.kOffWhite,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Kolors.kOffWhite,
                  ),
                  onTap: () {
                    // Add FAQ navigation here.
                  },
                ),

                SizedBox(height: 15.h),

                // Contact Us
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Kolors.kOffWhite,
                  ),
                ),

                SizedBox(height: 10.h),

                const Row(
                  children: [
                    Icon(
                      MaterialCommunityIcons.email_outline,
                      color: Kolors.kOffWhite,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        't.p.tshabalala98@gmail.com',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Kolors.kOffWhite,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                const Row(
                  children: [
                    Icon(
                      MaterialCommunityIcons.phone_outline,
                      color: Kolors.kOffWhite,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      '0763729362',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Kolors.kOffWhite,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Legal
                const Text(
                  'Legal',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Kolors.kOffWhite,
                  ),
                ),

                SizedBox(height: 10.h),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    MaterialCommunityIcons.file_document_outline,
                    color: Kolors.kOffWhite,
                  ),
                  title: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: Kolors.kOffWhite,
                    ),
                  ),
                  subtitle: const Text(
                    'Read the terms for using Plug.',
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Kolors.kOffWhite,
                  ),
                  onTap: () {
                    context.push('/terms');
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    MaterialCommunityIcons.shield_account_outline,
                    color: Kolors.kOffWhite,
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Kolors.kOffWhite,
                    ),
                  ),
                  subtitle: const Text(
                    'Learn how we collect and protect your data.',
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Kolors.kOffWhite,
                  ),
                  onTap: () {
                    context.push('/privacy');
                  },
                ),

                SizedBox(height: 24.h),

                // Full Help Center
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Kolors.kPrimary,
                      foregroundColor: Kolors.kOffWhite,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://plugwebsite.up.railway.app/',
                      );

                      try {
                        final launched = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );

                        if (!launched && sheetContext.mounted) {
                          FlushbarService.error(
                            sheetContext,
                            'Unable to open the website.',
                          );
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          debugPrint(
                            '❌ Failed to open website: $e',
                          );
                        }

                        if (!sheetContext.mounted) return;

                        FlushbarService.error(
                          sheetContext,
                          'Unable to open the website.',
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Visit Full Help Center',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      );
    },
  );
}

