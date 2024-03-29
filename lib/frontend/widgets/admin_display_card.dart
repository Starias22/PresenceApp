// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/frontend/screens/update_admin.dart';

class AdminDisplayCard extends StatefulWidget {
  final Admin admin;
  final bool himself;
   const AdminDisplayCard({Key? key, required this.admin,
     required this.himself}) : super(key: key);

  @override
  _AdminDisplayCardState createState() => _AdminDisplayCardState();
}

class _AdminDisplayCardState extends State<AdminDisplayCard> {
  bool deleteInProgress = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    height: 90.0,
                    width: 90.0,
                    child: Image.asset(
                      'assets/images/imsp1.png',
                      fit: BoxFit.fill,
                    ),
                  )),
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                               widget.admin.lastname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.admin.firstname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.admin.email,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                       deleteInProgress?
                       const CircularProgressIndicator
                         (color: Color.fromRGBO(255, 0, 0, 1),): DropdownButtonHideUnderline(
                            child: DropdownButton(
                          onChanged: (String? v)  {
                            if (v == "modifier") {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) {
                                  return UpdateAdmin(admin: widget.admin,himself: false,);
                                }),
                              );
                            } else if (v == "supprimer") {


                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        actionsAlignment:
                                            MainAxisAlignment.spaceAround,
                                        title: const Text(
                                            'Voulez-vous vraiment supprimer ?'),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(
                                                      255, 10, 184, 39),
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets.all(
                                                      8.0)),
                                              child: const Text("Annuler")),
                                          ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();

                                                setState(() {
                                                  deleteInProgress=true;
                                                });


                                                String? id=await AdminDB().getAdminIdByEmail
                                                  (widget.admin.email);
                                             AdminDB().delete(id!);
                                                setState(() {
                                                  deleteInProgress=false;
                                                });
                                                Navigator.of(context).pop();
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>

                                                        const AdminHomePage()));

                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (context) =>
                                                //
                                                //         const AdminsList()));

                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(
                                                      255, 184, 50, 10),
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets.all(
                                                      8.0)),
                                              child: const Text("Supprimer")),
                                        ],
                                      )).then((value) {
                              });
                            }
                          },
                          items: [

                         if( ! widget.admin.isSuper||
                             (widget.admin.isSuper&&widget.himself))  DropdownMenuItem(
                              value: 'modifier',
                              child: const Row(
                                children: [
                                  Text(
                                    'Modifier',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              onTap: () {
                             },
                            ),
                           if(!widget.admin.isSuper&&!widget.himself)
                             const DropdownMenuItem(
                              value: 'supprimer',
                              child: Row(
                                children: [
                                  Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              
                            )
                          ],
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.more_vert,
                              size: 25,
                            ),
                          ),
                        )
                        )
                      ],
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
