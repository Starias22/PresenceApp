import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    Key? key,
    required String message,
    required Widget image,
    double width=600,
    Duration duration = const Duration(seconds: 60),

  }) : super(
    width: width,
    showCloseIcon: true,
    key: key,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    content: Container(
      //width: width,
      constraints:
      const BoxConstraints(
        maxHeight: 100,
        maxWidth: 100, // Set your desired maximum width here
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Align children at the start (left)
        children: [

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: image,
          ),
          
          Expanded(
            child: Align(
               child: Text(message,overflow: TextOverflow.ellipsis,maxLines: 2,),

            ),
          ),
        ],
      ),

    ),
  );
}
