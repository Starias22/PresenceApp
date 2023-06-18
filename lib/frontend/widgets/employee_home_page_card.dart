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
            onEnter: (event) {

            },
            onExit: (event) {
            },
            child:Listener(
      onPointerDown: (event) {},
            child: GestureDetector(

              onTap: () {
                log.d('qqqqqqqq');

                final RenderBox? overlay = context.findRenderObject() as RenderBox?;
                if (overlay != null) {
                final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                overlay.localToGlobal(Offset.zero),
                overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
                ),
                Offset.zero & overlay.size,
                );

                showMenu(
                  context: context,
                  position: position,
                  items: [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Déconnexion'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'manageAccount',
                      child: Text('Gérer mon compte'),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    //_handleMenuSelection(value);
                  }
                });
                }

              },
              child: Tooltip(
              message:'Compte employé\n '
                  '${employee.firstname} ${employee.lastname}\n'
                  '${employee.email}' ,
                preferBelow: false,
                child: Hero(
                  tag: imageDownloadURL,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(imageDownloadURL),
                  ),
                ),
              ),
            )),
          ),
        )
      ],
    );
  }

}
