
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

Future<dynamic> showHelpCenterBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, 
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plug Provider App Help Center',
                  style: appStyle(18.0, Kolors.kOffWhite, FontWeight.bold),
                ),
                SizedBox(height: 10.h),

                Text(
                  'We\'re here to help! Find answers to frequently asked questions or contact our support team.',
                  textAlign: TextAlign.center,
                  style: appStyle(16.0, Kolors.kOffWhite, FontWeight.normal),
                ),
                SizedBox(height: 15.h),

                const Text(
                  'FAQs:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Kolors.kOffWhite,
                  ),
                ),
                const SizedBox(height: 5.0),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Can I reschedule an active booking?',
                      style: TextStyle(color: Kolors.kOffWhite)),
                  trailing: const Icon(Icons.keyboard_arrow_right,
                      color: Kolors.kOffWhite),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('How do I ensure my saftey?',
                      style: TextStyle(color: Kolors.kOffWhite)),
                  trailing: const Icon(Icons.keyboard_arrow_right,
                      color: Kolors.kOffWhite),
                  onTap: () {},
                ),

                SizedBox(height: 15.h),

                const Text(
                  'Contact Us:',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Kolors.kOffWhite),
                ),
                SizedBox(height: 10.h),

                const Row(
                  children: [
                    Icon(MaterialCommunityIcons.email_outline,
                        color: Kolors.kOffWhite),
                    SizedBox(width: 10.0),
                    Text('t.p.tshabalala98@gmail.com',
                        style: TextStyle(fontSize: 16.0, color: Kolors.kOffWhite)),
                  ],
                ),
                SizedBox(height: 20.h),

                const Row(
                  children: [
                    Icon(MaterialCommunityIcons.phone_outline,
                        color: Kolors.kOffWhite),
                    SizedBox(width: 10.0),
                    Text('0719503706',
                        style: TextStyle(fontSize: 16.0, color: Kolors.kOffWhite)),
                  ],
                ),
                SizedBox(height: 20.h),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Kolors.kPrimary,
                    foregroundColor: Kolors.kOffWhite,
                  ),
                  onPressed: () {},
                  child: const Text('Visit Full Help Center',style: TextStyle(fontSize: 16.0, color: Kolors.kOffWhite)),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
