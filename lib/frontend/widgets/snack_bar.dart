import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    Key? key,
    required String message,
    required Widget image,
    Duration duration = const Duration(seconds: 3),
    double width = 300, // Set your desired width here
  }) : super(

    width:900,// MediaQuery().of(context).size,
    key: key,
    duration: duration,
     behavior: SnackBarBehavior.floating,
    content: Container(
      width: width,
      constraints: const BoxConstraints(
        maxHeight: 100,
        maxWidth: 100, // Définissez la largeur maximale souhaitée
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: image,
            ),
            Text(message),
          ],
        ),
      ),
    ),
  );
}
