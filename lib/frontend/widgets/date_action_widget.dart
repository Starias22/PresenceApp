import 'package:flutter/material.dart';

class DateActionContainer extends Row {
  DateActionContainer({
    super.key,
    required String title,
    required String selectedDate,
    required void Function() onSelectDate,
  }) : super(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [


      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
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
      ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
        ),
        onPressed: () async {
          onSelectDate();
        },
        child: const Text('Modifier'),
      ),

    ],

  );
}