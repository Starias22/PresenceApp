import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/listeEmployes.dart';
import 'package:presence_app/frontend/screens/mesStatistiques.dart';
import 'package:presence_app/frontend/screens/pageModifierEmployer.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';


class AfficherEmployeCard extends StatelessWidget {
  final Employee employee;

    const AfficherEmployeCard({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const connectionError="Erreur de connexion! Veillez reessayer";

    return InkWell(
      onTap: () {

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
                          onChanged: (String? v) async {
                            if (v == "modifier") {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) {
                                  return FormulaireModifierEmploye(employee: employee,);

                                }),
                              );

                            } else if (v == "supprimer") {
                              String email=FirebaseAuth.instance.currentUser!.email!;
                              String adminId= (await AdminDB().getAdminIdByEmail(email))!;
                            if(!(await AdminDB().getAdminById(adminId)).isSuper){
                            ToastUtils.showToast(context, 'Seul le super admin peut supprimer des employés', 3);
                            return;

                            }
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


                                            String? id= await EmployeeDB().getEmployeeIdByEmail
                                              (employee.email);
                                          log.d(employee.lastname);
                                            int ?fingerprintId=
                                              ( employee).fingerprintId;



                                          if(fingerprintId!=null){
                                            log.d('Fingerprint id:$fingerprintId');
                                           if(!await ESP32().
                                           sendData(fingerprintId.toString()))
                                           {
                                               ToastUtils.showToast(context, connectionError, 3);
                                               return;
                                           }
                                           int data=await ESP32().receiveData();
                                           if(data==espConnectionFailed)
                                           {
                                             ToastUtils.showToast(context, connectionError, 3);
                                             return;
                                           }
                                           if(data!=1000) {
                                             ToastUtils.showToast(context, 'Echec de suppression', 3);
                                             return;
                                           }
                                          }
                                            EmployeeDB().delete(id!);

                                        Navigator.of(context).pop();
                                        //Navigator.of(context).pop();
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
