import 'package:flutter/material.dart';

import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/login_bottom_sheet.dart';
import 'package:flutter_application_2/common/storage.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Storage().getString('accessToken') != null) {
          // User is logged in, navigate to notifications screen
          Navigator.pushNamed(context, '/notifications');
        } else {
          // User is not logged in, navigate to login screen
          // Navigator.pushNamed(context, '/login');
          
          loginBottomSheet(context);        }
      },
      child: Padding(padding: const EdgeInsets.only(right: 11),
      child: CircleAvatar(
        backgroundColor: Kolors.kOffWhite.withOpacity(.3),
        child: Badge(
          label: Text("20"),
        child: const Icon(
          Icons.notifications,
          size: 20,
          color: Kolors.kOffWhite,
        ))
      ),
      
      // child: const Icon(
        
      //   Icons.notifications,
      //   size: 30,
      //   color: Colors.white,
      // ),
    ));
  }
}