import 'package:flutter/cupertino.dart';

class CustomMessage extends Text{

   CustomMessage({
    super.key,
    required String message,
    required  Color color}):
        super(message,
         style: TextStyle(fontSize: 15,
             color: color),
         textAlign: TextAlign.center,
       );
   static  CustomMessage  getText (String message,{int colorCode=3}){

     Color color;
      switch(colorCode){
        case 1 ://operation cancelled
          color=const Color.fromRGBO(0, 0, 0, 1);
          break;
        case 2 ://success
          color=const Color.fromRGBO(0, 255, 0, 0.1);
          break;
        case 3 ://error
          color=const Color.fromRGBO(255, 0, 0, 1);
          break;
        case 4 :// a task in progress
          color=const Color.fromRGBO(0, 0, 255, 1);
          break;
        case 5 ://waiting for user action
          color=const Color.fromRGBO(0, 0, 0, 1);
          break;
        default :
          color=const Color.fromRGBO(255, 255, 255, 0.5);
          break;

      }
      return CustomMessage(message: message,color: color,);

    }
}