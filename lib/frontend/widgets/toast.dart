
import 'package:flutter/material.dart';

class ToastUtils{
  static void showToast(BuildContext context,String message,int duration){


     ScaffoldMessenger.of(context).showSnackBar(SnackBar(

      content: Text(message),
      duration:Duration(seconds: duration),
    ));

  }
}