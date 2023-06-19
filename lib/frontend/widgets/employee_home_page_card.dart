// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/frontend/screens/login_menu.dart';
import 'package:presence_app/frontend/screens/monCompte.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
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
            onSelected: (value) async {
              if (value == "logout") {
                // Handle déconnexion option

                await Login().googleSingOut();
                log.d('Déconnexion selected');
                ToastUtils.showToast(context, 'Vous êtes déconnecté',3);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  const WelcomeImsp()));


              }
              else if (value == "handle") {
                // Handle Gérer mon compte option
                log.d('Gérer mon compte selected');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  const MonCompte()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

              const PopupMenuItem<String>(
                value: "handle",
                child: Text("Mon compte"),
              ),
              const PopupMenuItem<String>(
                value: "logout",
                child: Text("Déconnexion"),
              ),
            ],
          ),
      ],
    );
  }
}
