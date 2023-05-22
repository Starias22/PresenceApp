
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ToastUtils{
  static void showToast(BuildContext context,String message,int duration){


     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));

  }
}