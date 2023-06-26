import 'package:flutter/material.dart';

class DateActionContainer extends Row{

  DateActionContainer({super.key, required String title,required
  String selectedDate,
    required void Function()? onSelectDate }):super(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      const SizedBox(width: 10), // Espacement entre le titre et le champ de texte
      Container(
        width: 125, // Largeur du champ de texte encadré
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

          },
          child:const Text('Modifier'),
        ),
    ],
  );

}
