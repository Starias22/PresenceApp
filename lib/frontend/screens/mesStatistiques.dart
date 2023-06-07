import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/presence.dart';
import 'package:presence_app/frontend/screens/diagrammeBandes.dart';
import 'package:presence_app/frontend/screens/monCompte.dart';
import 'package:presence_app/frontend/screens/presence_details.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/calendrierCard.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

import 'package:provider/provider.dart';


class MesStatistiques extends StatefulWidget {
  String? email;
   MesStatistiques({Key? key,this.email}) : super(key: key);


  @override
  State<MesStatistiques> createState() => _MesStatistiquesState();
}

class _MesStatistiquesState extends State<MesStatistiques> {
late Presence presenceDoc;
  late DateTime startDate;
  String? employeeId;
  late String email;
  bool isLoading = true;
  late DateTime now,today;
  late DateTime nEntryTime,nExitTime;
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
  Map<DateTime, EStatus> _events = {};

  Future<void> retrieveReport() async {
    Map<DateTime,EStatus>x={};

    email=(widget.email ?? FirebaseAuth.instance.currentUser!.email)!;
    employeeId= await EmployeeDB().getEmployeeIdByEmail(email);
    log.d('Id de lemp: $employeeId');
    var employee=await EmployeeDB().getEmployeeById(employeeId!);
    nEntryTime=utils.format(employee.entryTime)!;
    nExitTime=utils.format(employee.exitTime)!;
    if(employee.status==EStatus.pending){
    x[employee.startDate]=EStatus.pending;
    ToastUtils.showToast(context, 'Employé en attente', 5);
    }
   now=await utils.localTime();
    today=DateTime(now.year,now.month,now.day);
    var y=(employee).startDate;
    if(x.isEmpty) {

      x = await PresenceDB().getMonthReport(employeeId!, today);
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
                  child: Text('Diagramme en bandes'),
                ),
                if(!Login().isSignedInWithPassword()) const PopupMenuItem(
                  value: 2,
                  child: Text('Mon compte'),
                ),
                if(!Login().isSignedInWithPassword()) const PopupMenuItem(
                  value: 3,
                  child: Text('Langue'),
                ),
                if(!Login().isSignedInWithPassword())  PopupMenuItem(
                  value: 4,
                  child: Text(appSettings.isDarkMode ? 'Mode lumineux' : 'Mode sombre'),
                ),
                if(!Login().isSignedInWithPassword())  const PopupMenuItem(
                  value: 5,
                  child: Text('Signaler un problème'),
                ),
                if(!Login().isSignedInWithPassword())  const PopupMenuItem(
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

                  await Provider.of<AppSettings>(context, listen: false).setDarkMode(
                    !Provider.of<AppSettings>(context, listen: false).isDarkMode,
                  );


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
                 /* Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Welcome()))*/
              Navigator.pop(context)
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
    onDayLongPressed: onDayLongPressed,
    onCalendarChanged: onCalendarChanged,
    minSelectedDate: startDate,
    ),
    ],
      ),
    ));
  }

  onDayLongPressed(DateTime date) async {

    if(utils.isWeekend(date)){
      ToastUtils.showToast(context, 'Weekend', 3);
    }

    if((!utils.isWeekend(date))&&(date.isBefore(today)||date.isAtSameMomentAs(today))) {
      String? presenceId = await PresenceDB().getPresenceId(date, employeeId!);

      Presence myPresence = await PresenceDB().getPresenceById(presenceId!);



      if(myPresence.status==EStatus.absent) {
        ToastUtils.showToast(context, 'Absent', 3);
      }
else {
  Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              PresenceDetails(presence: myPresence, nEntryTime: nEntryTime,
                nExitTime: nExitTime,),
        ),
      );
}
    }
  }
}
