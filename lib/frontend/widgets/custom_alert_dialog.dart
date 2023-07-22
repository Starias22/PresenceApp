
import 'package:flutter/material.dart';

import 'custom_button.dart';
class CustomAlertDialog extends AlertDialog{

   CustomAlertDialog({super.key,required String title,required String message,
     required String positiveOption,String?negativeOption,
     required BuildContext context,
      void Function()? onConfirm,
     void Function()? onCancel,
   }):
        super(
           title:Text(title) ,
           content: Text(message),
         actions: <Widget>[
           CustomElevatedButton(
             text: positiveOption,
             onPressed: () async {
               Navigator.of(context).pop();
               onConfirm!();
             },
           ),
           if(negativeOption!=null) CustomElevatedButton(
             text:negativeOption,
             onPressed: () {
               // Ajoutez ici le code à exécuter lorsque l'utilisateur confirme
               Navigator.of(context).pop(); // Ferme la boîte de dialogue
             onCancel!();
             },
           ),
         ],
       );

}