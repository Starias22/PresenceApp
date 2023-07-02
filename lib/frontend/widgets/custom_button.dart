import 'package:flutter/material.dart';
import 'package:presence_app/utils.dart';

class CustomElevatedButton extends ElevatedButton
{
  CustomElevatedButton
      ({super.key, required String text,
    required void Function() onPressed,}):
        super(
        child: Text(text),
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.
          all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
          ),
          backgroundColor:
          MaterialStateProperty.
          all<Color>(appBarColor),
        ),
      );

}