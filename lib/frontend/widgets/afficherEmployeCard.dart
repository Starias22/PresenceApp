import 'package:flutter/material.dart';
import 'package:presence_app/utils.dart';

import '../../new_back/firestore/employee_db.dart';
import '../../new_back/models/employee.dart';
import '../screens/listeEmployes.dart';
import '../screens/mesStatistiques.dart';
import '../screens/pageModifierEmployer.dart';

class AfficherEmployeCard extends StatelessWidget {
  final Employee employee;

    const AfficherEmployeCard({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        log.d("tapppp");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return MesStatistiques(email: employee.email,);

          }),
        );
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
                                employee.lastname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                employee.firstname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                employee.service,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                utils.str(employee.status),
                                style: const TextStyle(
                                  //color: color()
                                  //if(employe.EtatPresence.present)
                                  //color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownButtonHideUnderline(
                            child: DropdownButton(
                          onChanged: (String? v) {
                            if (v == "modifier") {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) {
                                  return FormulaireModifierEmploye(employee: employee,);

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
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 10, 184, 39),
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets.all(
                                                      8.0)),
                                              child: const Text("Annuler")),
                                          ElevatedButton(
                                              onPressed: () async {

                                            String? id= await EmployeeDB().getEmployeeIdByEmail(employee.email);
                                            EmployeeDB().delete(id!);
                                        Navigator.of(context).pop();
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const AfficherEmployes()));


;
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 184, 50, 10),
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets.all(
                                                      8.0)),
                                              child: const Text("Supprimer")),
                                        ],
                                      )).then((value) {
                                //setState(() {});
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'modifier',
                              child: Row(
                                children: [
                                  Text(
                                    'Modifier',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),

                            ),
                            DropdownMenuItem(
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
                        ))
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
