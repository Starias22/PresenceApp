import 'package:flutter/material.dart';

import 'custom_button.dart';

class DateActionRow extends Row {
  DateActionRow({
    super.key,
    required String title,
    required String selectedDate,
    required void Function() onSelectDate,
    bool? dateChanging
  }) : super(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [


      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(width: 10),
      Flexible( // Add Flexible widget
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.all(10),
          child: Text(
            selectedDate,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),

      dateChanging==null||dateChanging==false?
      CustomElevatedButton(
        onPressed: () async {
          onSelectDate();
        },
       text: 'Modifier',
      ):const CircularProgressIndicator(),

    ],

  );
}
