import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/day.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/backend/services/presence_manager.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

import '../widgets/calendrierCard.dart';
import 'diagrammeBandes.dart';
import 'monCompte.dart';

class MesStatistiques extends StatefulWidget {
  const MesStatistiques({Key? key}) : super(key: key);

  @override
  State<MesStatistiques> createState() => _MesStatistiquesState();
}

class _MesStatistiquesState extends State<MesStatistiques> {
  Map<DateTime, EStatus> _events = {};
  
  Future<void> retrieveReport() async {
    String? email = FirebaseAuth.instance.currentUser!.email;
    var employee = Employee.target(email!);
    var x = await PresenceManager().getMonthReport(employee, Day.today());
    setState(() {
      _events = x;
      _events.forEach((key, value) {
        log.i('date:$key status:$value');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Mes statistiques",
          style: TextStyle(
            fontSize: 23,
          ),
        ),
        actions: [
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                // size: 30,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 1,
                  child: Text('Statistiques'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Mon compte'),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text('Langue'),
                ),
                const PopupMenuItem(
                  value: 4,
                  child: Text('Mode sombre'),
                ),
                const PopupMenuItem(
                  value: 5,
                  child: Text('Signaler un problème'),
                ),
                const PopupMenuItem(
                  value: 6,
                  child: Text('Déconnexion'),
                ),
              ],
              onSelected: (value) {
                if (value == 1) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DiagrammeBar()));
                } else if (value == 2) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MonCompte()));
                } else if (value == 3) {
                } else if (value == 4) {
                } else if (value == 5) {
                  // action pour l'option 5
                } else if (value == 6) {
                  // action pour l'option 6

                  EmployeeManager().signOut();
                  ToastUtils.showToast(
                      context, 'Vous êtes déconnecté', 3);

                  Future.delayed(const Duration(seconds: 3),
                          () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const Welcome();
                            }));
                      });

                }
              },
            ),
          )
        ],
        leading: IconButton(
            onPressed: () => {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Welcome()))
                },
            icon: const Icon(
              Icons.arrow_back,
            )),
      ),
      body: CalendrierCard(
        events: _events,
      ),
    );
  }
}
