// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';
import 'package:presence_app/frontend/screens/admins_list.dart';
import 'package:presence_app/frontend/screens/handle.dart';
import 'package:presence_app/frontend/screens/update_admin.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class HolidayDisplayCard extends StatelessWidget {
  final Holiday holiday;
  const HolidayDisplayCard({Key? key, required this.holiday}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ManageHolidays(holiday: holiday);
            },
          ),
        );
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
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
                                  Center(
                                    child: Text(
                                      utils.str(holiday.type),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    holiday.getRange(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                   Center(
                                      child:   Text(
                                        holiday.employeesIds!.isEmpty?'Tous':
                                        holiday.employeesIds!.length.toString(),
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    )
                                // ),
                              ],
                            ),
                            DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  onChanged: (String? v)  {
                                    if (v == "details") {

                                    }
                                    if (v == "update") {

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (BuildContext context) {
                                      //     return UpdateAdmin(admin: holiday,himself: false,);
                                      //   }),
                                      // );
                                    }


                                    // else if (v == "supprimer") {
                                    //
                                    //   showDialog(
                                    //       context: context,
                                    //       builder: (context) => AlertDialog(
                                    //         actionsAlignment:
                                    //         MainAxisAlignment.spaceAround,
                                    //         title: const Text(
                                    //             'Voulez-vous vraiment supprimer ?'),
                                    //         actions: [
                                    //           ElevatedButton(
                                    //               onPressed: () {
                                    //                 Navigator.of(context).pop();
                                    //               },
                                    //               style: ElevatedButton.styleFrom(
                                    //                   backgroundColor: const Color.fromARGB(
                                    //                       255, 10, 184, 39),
                                    //                   shape: const StadiumBorder(),
                                    //                   padding: const EdgeInsets.all(
                                    //                       8.0)),
                                    //               child: const Text("Annuler")),
                                    //           ElevatedButton(
                                    //               onPressed: () async {
                                    //
                                    //                 // String? id=await AdminDB().
                                    //                 // getAdminIdByEmail(holiday.email);
                                    //                 // AdminDB().delete(id!);
                                    //                 //
                                    //                 //
                                    //                 // Navigator.of(context).pop();
                                    //
                                    //                 Navigator.pushReplacement(
                                    //                     context,
                                    //                     MaterialPageRoute(
                                    //                         builder: (context) => const AdminsList()));
                                    //
                                    //
                                    //               },
                                    //               style: ElevatedButton.styleFrom(
                                    //                   backgroundColor: const Color.fromARGB(
                                    //                       255, 184, 50, 10),
                                    //                   shape: const StadiumBorder(),
                                    //                   padding: const EdgeInsets.all(
                                    //                       8.0)),
                                    //               child: const Text("Supprimer")),
                                    //         ],
                                    //       )).then((value) {
                                    //   });
                                    // }
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: 'details',
                                      child: const Row(
                                        children: [
                                          Text(
                                            'Détails',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                      },
                                    ),
                                    const DropdownMenuItem(
                                      value: 'update',
                                      child: Row(
                                        children: [
                                          Text(
                                            'Modifier',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),

                                    ),

                                    // const DropdownMenuItem(
                                    //   value: 'delete',
                                    //   child: Row(
                                    //     children: [
                                    //       Text(
                                    //         'Supprimer',
                                    //         style: TextStyle(color: Colors.black),
                                    //       ),
                                    //     ],
                                    //   ),
                                    //
                                    // )
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
