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
    final items = (await FirebaseStorage.instance.ref().listAll()).items;

    log.d('items.. $items');

    var x = items.where(
            (item) => item.name.startsWith(RegExp('^${widget.employee.id}')));

    try {
      String filename = items
          .where((item) =>
          item.name.startsWith(RegExp('^${widget.employee.id}')))
          .toList()[0]
          .name;

      log.d('filename: $filename');
      return await FirebaseStorage.instance
          .ref()
          .child(filename)
          .getDownloadURL();
    } catch (e) {
      return "";
    }
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
                  child: imageDownloadUrl == ''
                      ? Image.asset(
                    'assets/images/imsp1.png',
                    fit: BoxFit.fill,
                  )
                      : Image.network(imageDownloadUrl),
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
                                            String? id = await EmployeeDB()
                                                .getEmployeeIdByEmail(
                                                widget.employee.email);
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
                                              int data = await ESP32()
                                                  .receiveData();
                                              if (data == espConnectionFailed) {
                                                ToastUtils.showToast(
                                                    context,
                                                    connectionError,
                                                    3);
                                                return;
                                              }
                                              if (data != 1000) {
                                                ToastUtils.showToast(
                                                    context,
                                                    'Echec de suppression',
                                                    3);
                                                return;
                                              }
                                            }
                                            EmployeeDB().delete(id!);

                                            Navigator.of(context).pop();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                const AfficherEmployes(),
                                              ),
                                            );
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
