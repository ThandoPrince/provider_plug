import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Padding(padding: const EdgeInsets.only(right: 12),
      child: CircleAvatar(
        backgroundColor: Kolors.kOffWhite.withOpacity(.3),
        child: const Icon(
          Icons.location_on,
          size: 20,
          color: Kolors.kOffWhite,
        )
      ),
      
      // child: const Icon(
        
      //   Icons.notifications,
      //   size: 30,
      //   color: Colors.white,
      // ),
    ));
  }
}