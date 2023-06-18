import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/utils.dart';

class HomePageCard extends StatefulWidget {
  final Employee employee;
  final String imageDownloadURL;

  const HomePageCard({Key? key, required this.employee, required this.imageDownloadURL})
      : super(key: key);

  @override
  _HomePageCardState createState() => _HomePageCardState();
}

class _HomePageCardState extends State<HomePageCard> {
  bool showMenu = false;

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
                setState(() {
                  showMenu = !showMenu;
                });
              },
              child: Tooltip(
                message: 'Compte employé\n '
                    '${widget.employee.firstname} ${widget.employee.lastname}\n'
                    '${widget.employee.email}',
                preferBelow: false,
                child: Hero(
                  tag: widget.imageDownloadURL,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(widget.imageDownloadURL),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showMenu)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "déconnexion") {
                // Handle déconnexion option
                log.d('Déconnexion selected');
              } else if (value == "Gérer mon compte") {
                // Handle Gérer mon compte option
                log.d('Gérer mon compte selected');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: "déconnexion",
                child: Text("Déconnexion"),
              ),
              const PopupMenuItem<String>(
                value: "Gérer mon compte",
                child: Text("Gérer mon compte"),
              ),
            ],
          ),
      ],
    );
  }
}
