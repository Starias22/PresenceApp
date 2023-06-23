import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {


  CustomSnackBar({
    Key? key,
    required String message,
     Widget? image,
    bool simple=false,
    bool showCloseIcon=false,
    double width = 600,
    Duration duration = const Duration(seconds: 60),

  }) : super(

    width:simple? null: width,
    closeIconColor: const Color.fromRGBO(255, 255, 255, 0.5),
    showCloseIcon: showCloseIcon,
    key: key,
    duration: duration,
    behavior:simple? null: SnackBarBehavior.floating,
    content:  Container(

      //width: width,
      constraints: simple? null:
       const BoxConstraints(
        maxHeight: 100,
        maxWidth: 100, // Set your desired maximum width here
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align children at the start (left)
        children: [

         if(!simple ) Padding(
            padding: const EdgeInsets.only(right: 10),
            child: image,
          ),

          Expanded(
            child: Align(
              child: Text(
                message, overflow: TextOverflow.ellipsis, maxLines: 2,),

            ),
          ),
        ],
      ),

    ),
  );

}