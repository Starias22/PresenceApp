// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/presence_calendar.dart';
import 'package:presence_app/frontend/screens/update_employee.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  bool forHoliday;
  bool? isChecked;
  final Function(Employee, bool)? onEmployeeChecked; // Add this line

   EmployeeCard({Key? key, required this.employee,
   this.forHoliday=false,
   this.isChecked=false,
     required this.onEmployeeChecked})
      : super(key: key);

  @override
  _EmployeeCardState createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  String imageDownloadUrl = '';
  bool isChecked = false;

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

  String connectionError = "Erreur de connexion! Veillez reessayer";

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

     if(!widget.forHoliday) {
       Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return PresenceCalendar(
              email: widget.employee.email,
            );
          }),
        );
     }
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
               if(widget.forHoliday) Checkbox(
                  value: widget.isChecked,
                 onChanged: (value) {
                   setState(() {
                     widget.isChecked = value ?? false;
                   });
                   if (widget.onEmployeeChecked != null) {
                     widget.onEmployeeChecked!(
                         widget.employee, widget.isChecked!);
                   }
                 },
                ),
                          if(!widget.forHoliday)   DropdownButtonHideUnderline(
                            child: DropdownButton(
                              onChanged: (String? v) async {
                                if (v == "modifier") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return UpdateEmployee(
                                          employee: widget.employee,
                                        );
                                      },
                                    ),
                                  );
                                } else if (v == "supprimer")
                                {

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

                                            log.d('The fingerprintId is: '
                                                '$fingerprintId');

                                            if (fingerprintId != null) {

                                              log.d('Fingerprint id:$fingerprintId');

                                              await ESP32()
                                                  .sendData(
                                                  'remove');

                                              // if (!await ESP32()
                                              //     .sendData(
                                              //     fingerprintId.toString())) {
                                              //
                                              //   ToastUtils.showToast(
                                              //       context,
                                              //       connectionError,
                                              //       3);
                                              //   return;
                                              // }

                                              //int data = await ESP32().receiveData();
                                              int data=-999;

                                              log.d('data: $data');

                                              if (data == 2000) {

                                                ToastUtils.showToast(
                                                    context,
                                                    'Employé supprimé avec succès',
                                                    3);
                                                //delete the employee

                                                //EmployeeDB().delete(id!);

                                                // Navigator.of(context).pop();
                                                // Navigator.pushReplacement(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //     builder: (context) =>
                                                //     EmployeesList(),
                                                //   ),
                                                // );
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
