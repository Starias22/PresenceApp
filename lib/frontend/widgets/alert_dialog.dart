
import 'package:flutter/material.dart';
class CustomDialog extends AlertDialog{

   CustomDialog({super.key,required String title,required String message,
     required BuildContext context}):
        super(
           title:Text(title) ,
           content: Text(message),
         actions: <Widget>[
           TextButton(
             child: const Text('Continuer'),
             onPressed: () async {
               Navigator.of(context).pop();
             },
           ),
         ],
       );

}