// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/employees_list.dart';
import 'package:presence_app/frontend/screens/presence_calendar.dart';
import 'package:presence_app/frontend/screens/update_employee.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  final bool forHoliday;
  bool? isChecked;
  bool? isSuperAdmin ;
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
  bool deleteInProgress=false;
  bool? isSuperAdmin;

  @override
  void initState() {
    super.initState();
    retrieve();

    // Call getDownloadURL and update imageDownloadUrl
    getDownloadURL().then((url) {
      setState(() {
        imageDownloadUrl = url;

      });
    });
  }
  Future<int> getData(int val) async {
    int data = val;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();
      if (cpt == 10 ||( data != val && data!=-1)) {
        log.d('Condition satisfied');
        return data;
      } else {
        cpt++;
        await Future.delayed(const Duration(seconds: 1));
        return await fetchData();
      }
    }

    return await fetchData();
  }

  Future<String> getDownloadURL() async {
    return '';
  }
  Future<void> retrieve() async {

    String? email=FirebaseAuth.instance.currentUser?.email;
    var x=(await AdminDB().getAdminByEmail(email!)).isSuper;
    setState(() {
    isSuperAdmin=x ;
    });
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
                            child: deleteInProgress?
                            const CircularProgressIndicator(
                              color: Color.fromRGBO(255, 0, 0, 0),
                            ):
                             DropdownButton(
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
                                             setState(() {
                                               deleteInProgress=false;
                                             });
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
                                              int data = await getData(150);

                                              log.d('datauuuuu: $data');
                                              if(data == -11){
                                                await ESP32()
                                                    .sendData(
                                                    fingerprintId.toString());

                                                data = await getData(-11);
                                                log.d('dataaaaaaaa: $data');
                                                if(data == 2000){
                                                  await ESP32()
                                                      .sendData(
                                                      'enroll');
                                                  log.d('Succès');

                                                 String id=(await  EmployeeDB().
                                                 getEmployeeByFingerprintId(fingerprintId))!.id;
                                                  //delete the employee

                                                  EmployeeDB().delete
                                                    (id);

                                                  Navigator.of(context).pop();
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                      const EmployeesList(),
                                                    ),
                                                  );
                                                  // ToastUtils.showToast(
                                                  //     context,
                                                  //     'Employé supprimé avec succès',
                                                  //     3);


                                                }else{
                                                  await ESP32()
                                                      .sendData(
                                                      'enroll');
                                                  log.d('Echec');
                                                  ToastUtils.showToast(
                                                      context,
                                                      'Echec de la suppression',
                                                      3);

                                                }


                                              }else{
                                                ToastUtils.showToast(
                                                    context,
                                                    'Problème de connection. Erreur de la suppression.',
                                                    3);
                                              }

                                            }
                                            setState(() {
                                              deleteInProgress=false;
                                            });

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

                                  });
                                }
                              },
                              items: [
                                const DropdownMenuItem(
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
                               if( isSuperAdmin==true) const DropdownMenuItem(
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
