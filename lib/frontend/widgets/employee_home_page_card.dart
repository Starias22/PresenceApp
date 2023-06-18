import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/utils.dart';

class HomePageCard extends StatelessWidget {
  final Employee employee;
  final String imageDownloadURL;

  const HomePageCard({Key? key, required this.employee, required this.imageDownloadURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Text(
        "My Home Page",
      ),
      elevation: 1,
      floating: true,
      forceElevated: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: MouseRegion(
            onEnter: (event) {},
            onExit: (event) {},
            child: InkWell(
              onTap: () {
                log.d('qqqqqqqq');
              },
              child: Tooltip(
                message: 'Compte employé\n '
                    '${employee.firstname} ${employee.lastname}\n'
                    '${employee.email}',
                preferBelow: false,
                child: Hero(
                  tag: imageDownloadURL,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(imageDownloadURL),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
      flexibleSpace: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(right: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            onChanged: (value) {
              if (value == "déconnexion") {
                // Handle déconnexion option
                log.d('Déconnexion selected');
              } else if (value == "Gérer mon compte") {
                // Handle Gérer mon compte option
                log.d('Gérer mon compte selected');
              }
            },
            items: const [
              DropdownMenuItem(
                value: "déconnexion",
                child: Text("Déconnexion"),
              ),
              DropdownMenuItem(
                value: "Gérer mon compte",
                child: Text("Gérer mon compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
