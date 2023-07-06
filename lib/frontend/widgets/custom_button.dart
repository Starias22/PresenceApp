import 'package:flutter/material.dart';
import 'package:presence_app/utils.dart';

class CustomElevatedButton extends ElevatedButton
{
  CustomElevatedButton
      ({super.key, required String text,
    required void Function() onPressed,
  double? height, double? width}):
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

class MenuButton extends Container{
  MenuButton({super.key,
    required String text,
    required void Function() onPressed,
    // required double height,
    required double width,
  }):super(
    width: width,
    // height: height,
    child: ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
      ),
      onPressed: (){
        onPressed();
      },
      child: Text(text),
    ),

  )
  ;

}