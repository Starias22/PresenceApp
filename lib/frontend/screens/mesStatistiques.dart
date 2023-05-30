import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/new_back/firestore/employee_db.dart';
import 'package:presence_app/backend/new_back/firestore/presence_db.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';

import 'package:provider/provider.dart';

import '../../backend/new_back/models/employee.dart' as emp;
import '../../backend/services/login.dart';
import '../../utils.dart';
import '../app_settings.dart';
import '../widgets/calendrierCard.dart';
import 'diagrammeBandes.dart';
import 'monCompte.dart';

class MesStatistiques extends StatefulWidget {
  String? email;
   MesStatistiques({Key? key,this.email}) : super(key: key);

  @override
  State<MesStatistiques> createState() => _MesStatistiquesState();
}

class _MesStatistiquesState extends State<MesStatistiques> {

  late DateTime startDate;
  String? employeeId;
  late String email;
  bool isLoading = true;
  //String? email = FirebaseAuth.instance.currentUser!.email;
  Future<void> onCalendarChanged(DateTime newMonth) async {
    setState(() {
      isLoading = true;
    });
      var newEventsData = await PresenceDB().getMonthReport(employeeId!, newMonth);
      log.i('new events: $newEventsData');
      setState(() {
        _events = newEventsData;
        isLoading = false;
      });

  }

  bool isDarkMode = false;
  Map<DateTime, emp.EStatus> _events = {};

  Future<void> retrieveReport() async {
    Map<DateTime,emp.EStatus>x={};
    log.d('/////');
    email=(widget.email ?? FirebaseAuth.instance.currentUser!.email)!;
    employeeId= await EmployeeDB().getEmployeeIdByEmail(email);
    var employee=await EmployeeDB().getEmployeeById(employeeId!);
    if(employee.status==emp.EStatus.pending){
    x[employee.startDate]=emp.EStatus.pending;
    ToastUtils.showToast(context, 'Employé en attente', 5);
    }
    //log.d('/////');
    var y=(employee).startDate;
    if(x.isEmpty) {
      //log.d('11111111');
      x = await PresenceDB().getMonthReport(employeeId!, DateTime.now());
    }


    setState(() {

      _events = x;
      startDate=y;
      isLoading=false;

    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    retrieveReport();
  }

  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);
    // Obtain the AppSettings instance from the Provider
    return Theme(
        data: appSettings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
    child: Scaffold(
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
                 PopupMenuItem(
                  value: 4,
                  child: Text(appSettings.isDarkMode ? 'Mode lumineux' : 'Mode sombre'),
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
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  DiagrammeBar(email: widget.email,)));
                } else if (value == 2) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MonCompte()));
                } else if (value == 3) {
                } else if (value == 4) {

                  log.d('dark?${Provider.of<AppSettings>(context, listen: false).isDarkMode}');
                  await Provider.of<AppSettings>(context, listen: false).setDarkMode(
                    !Provider.of<AppSettings>(context, listen: false).isDarkMode,
                  );
                  log.d('dark?${Provider.of<AppSettings>(context, listen: false).isDarkMode}');

                  // Exit the app to trigger the restart
                //SystemNavigator.pop();
                } else if (value == 5) {
                  // action pour l'option 5
                } else if (value == 6) {
                  // action pour l'option 6

                  Login().googleSingOut();
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
      body: Stack(
          children: [
          if (_events.isEmpty)
        const Center(
        child: CircularProgressIndicator(),
    )
    else
    CalendrierCard(
    events: _events,
    onCalendarChanged: onCalendarChanged,
    minSelectedDate: startDate,
    ),
    ],
      ),
    ));
  }
}
