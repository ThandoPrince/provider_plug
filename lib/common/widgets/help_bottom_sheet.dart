
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

Future<dynamic> showHelpCenterBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // 👈 Important for gradient
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
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
                  style: appStyle(18.0, Colors.black, FontWeight.bold),
                ),
                SizedBox(height: 10.h),

                Text(
                  'We\'re here to help! Find answers to frequently asked questions or contact our support team.',
                  textAlign: TextAlign.center,
                  style: appStyle(16.0, Colors.black, FontWeight.normal),
                ),
                SizedBox(height: 15.h),

                const Text(
                  'FAQs:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5.0),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Can I reschedule an active booking?',
                      style: TextStyle(color: Colors.black)),
                  trailing: const Icon(Icons.keyboard_arrow_right,
                      color: Colors.black),
                  onTap: () {},
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('How do I ensure my saftey?',
                      style: TextStyle(color: Colors.black)),
                  trailing: const Icon(Icons.keyboard_arrow_right,
                      color: Colors.black),
                  onTap: () {},
                ),

                SizedBox(height: 15.h),

                const Text(
                  'Contact Us:',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 10.h),

                const Row(
                  children: [
                    Icon(MaterialCommunityIcons.email_outline,
                        color: Colors.black),
                    SizedBox(width: 10.0),
                    Text('t.p.tshabalala98@gmail.com',
                        style: TextStyle(fontSize: 16.0, color: Colors.black)),
                  ],
                ),
                SizedBox(height: 20.h),

                const Row(
                  children: [
                    Icon(MaterialCommunityIcons.phone_outline,
                        color: Colors.black),
                    SizedBox(width: 10.0),
                    Text('0719503706',
                        style: TextStyle(fontSize: 16.0, color: Colors.black)),
                  ],
                ),
                SizedBox(height: 20.h),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Kolors.kPrimary,
                  ),
                  onPressed: () {},
                  child: const Text('Visit Full Help Center',style: TextStyle(fontSize: 16.0, color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
