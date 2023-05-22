import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget SearchBar({required void Function(String) onChange}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
    child: CupertinoSearchTextField(
        onChanged: onChange,
        padding: const EdgeInsets.all(15),
        prefixInsets: const EdgeInsets.only(left: 15),
        placeholder: 'Rechercher',
        prefixIcon: const Icon(Icons.search),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: List.generate(4, (index) {
              return BoxShadow(
                  offset: const Offset(2.0, 2.0),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                  color: Colors.grey.shade100
              );
            }))
    ),
  );
}
