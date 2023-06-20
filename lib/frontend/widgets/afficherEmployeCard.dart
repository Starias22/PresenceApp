// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/employees_list.dart';
import 'package:presence_app/frontend/screens/mesStatistiques.dart';
import 'package:presence_app/frontend/screens/pageModifierEmployer.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class AfficherEmployeCard extends StatefulWidget {
  final Employee employee;

  const AfficherEmployeCard({Key? key, required this.employee})
      : super(key: key);

  @override
  _AfficherEmployeCardState createState() => _AfficherEmployeCardState();
}

class _AfficherEmployeCardState extends State<AfficherEmployeCard> {
  String imageDownloadUrl = '';

  @override
  void initState() {
    super.initState();
    // Call getDownloadURL and update imageDownloadUrl
    getDownloadURL().then((url) {
      setState(() {
        imageDownloadUrl = url;
      });
    });
  }

  Future<String> getDownloadURL() async {
    return '';
  }

  Future<int> assureDataChanged(int fingerprintId,int val ) async {
    int data = fingerprintId ;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();

      if (cpt == 10) {

        return 152;
      }


      if (data ==val) {
        log.d('Data changed');
        return data;
      }
      else {
        cpt++;
        await Future.delayed(const Duration(seconds: 1));
        return await fetchData();
      }

    }

    return await fetchData();
  }

  String connectionError = "Erreur de connexion! Veillez reessayer";

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return MesStatistiques(
              email: widget.employee.email,
            );
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
                  child: widget.employee.pictureDownloadUrl== null
                      ? Image.asset(
                    'assets/images/imsp1.png',
                    fit: BoxFit.fill,
                  )
                      : Image.network(widget.employee.pictureDownloadUrl!),
                ),
              ),
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
                                  widget.employee.lastname,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.employee.firstname,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.employee.service,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  utils.str(widget.employee.status),
                                  style: const TextStyle(
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
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return FormulaireModifierEmploye(
                                          employee: widget.employee,
                                        );
                                      },
                                    ),
                                  );
                                } else if (v == "supprimer") {
                                  String email =
                                  FirebaseAuth.instance.currentUser!.email!;
                                  String adminId = (await AdminDB()
                                      .getAdminIdByEmail(email))!;
                                  if (!(await AdminDB()
                                      .getAdminById(adminId))
                                      .isSuper) {
                                    ToastUtils.showToast(
                                        context,
                                        'Seul le super admin peut supprimer des employés',
                                        3);
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
                                            padding: const EdgeInsets.all(8.0),
                                          ),
                                          child: const Text("Annuler"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            log.d(widget.employee.lastname);
                                            int? fingerprintId =
                                                widget.employee.fingerprintId;

                                            if (fingerprintId != null) {

                                              log.d('Fingerprint id:$fingerprintId');
                                              if (!await ESP32()
                                                  .sendData(
                                                  fingerprintId.toString())) {

                                                ToastUtils.showToast(
                                                    context,
                                                    connectionError,
                                                    3);
                                                return;
                                              }

                                              // int data = await assureDataChanged(fingerprintId, 2000);
                                              int data = await ESP32().receiveData();
                                              log.d('data: $data');

                                              if (data == 2000) {

                                                ToastUtils.showToast(
                                                    context,
                                                    'Employé supprimé avec succès',
                                                    3);
                                                //delete the employee

                                                //EmployeeDB().delete(id!);

                                                Navigator.of(context).pop();
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                    const AfficherEmployes(),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (data == espConnectionFailed) {

                                                ToastUtils.showToast(
                                                    context,
                                                    connectionError,
                                                    3);
                                                return;
                                              }

                                            }

                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color.fromARGB(
                                                255, 184, 50, 10),
                                            shape: const StadiumBorder(),
                                            padding: const EdgeInsets.all(8.0),
                                          ),
                                          child: const Text("Supprimer"),
                                        ),
                                      ],
                                    ),
                                  ).then((value) {
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
