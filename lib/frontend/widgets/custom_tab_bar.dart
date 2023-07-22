import 'package:flutter/material.dart';

class CustomTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  const CustomTab({Key? key, required this.text, this.isSelected = false,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
            color: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
          )),
      child: Text(
        text,
        style: TextStyle(
          //fontSize: 15,
          color:
          isSelected ? Colors.green : Colors.black,
        ),
      ),
    );
  }
}