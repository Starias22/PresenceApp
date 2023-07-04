// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/presence.dart';
import 'package:presence_app/frontend/screens/monCompte.dart';
import 'package:presence_app/frontend/screens/presence_details.dart';
import 'package:presence_app/frontend/screens/login_menu.dart';
import 'package:presence_app/frontend/screens/statistics_by_intervals.dart';
import 'package:presence_app/frontend/widgets/calendrierCard.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';
import 'package:presence_app/utils.dart';

import 'package:provider/provider.dart';


class PresenceCalendar extends StatefulWidget {

  String? email;
   PresenceCalendar({Key? key,this.email}) : super(key: key);


  @override
  State<PresenceCalendar> createState() => _PresenceCalendarState();
}

class _PresenceCalendarState extends State<PresenceCalendar> {
  final _key = GlobalKey<FormState>();
  late String _valueChanged;

late Presence presenceDoc;
  late Employee employee;
  late DateTime startDate;
  late String email;
  bool isLoading = true;
  late DateTime now,today;
  Future<void> onCalendarChanged(DateTime newMonth) async {
    setState(() {
      isLoading = true;
    });

      var newEventsData = await PresenceDB().getMonthReport(employee.id, newMonth);
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
    log.d('The email of the employee is : ${widget.email}');
    log.d('The email of the employee is : $email');
    employee=await EmployeeDB().getEmployeeByEmail(email);


    if(employee.status==EStatus.pending){
    x[employee.startDate]=EStatus.pending;
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
      simple: true,
      showCloseIcon: false,
      duration: const Duration(seconds: 5) ,
      //width: MediaQuery.of(context).size.width-2*10,
      message:'Employé en attente' ,
    ));

    }

   now=await utils.localTime();
    today=DateTime(now.year,now.month,now.day);
    var y=(employee).startDate;
    log.d('Still working  ok');
    if(x.isEmpty) {
      log.d('Still working  ok ok');
      log.d('The id of the employee: ${employee.id}');
      x = await PresenceDB().getMonthReport(employee.id, today);
      log.d('Still working  ok ok ok');
    }
    log.d('Still working ok ok ok ok');


    setState(() {

      log.d('The events: $_events');

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
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text(
          "Calendrier des présences",
          // style: TextStyle(
          //   //fontSize: 23,
          // ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              // size: 30,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if(widget.email!=null) const PopupMenuItem(
                value: 1,
                child: Text('Statistiques par intervalles'),
              ),
              if(widget.email==null) const PopupMenuItem(
                value: 2,
                child: Text('Mon compte'),
              ),
              if(widget.email==null) const PopupMenuItem(
                value: 3,
                child: Text('Langue'),
              ),
              if(widget.email==null)  PopupMenuItem(
                value: 4,
                child: Text(appSettings.isDarkMode ? 'Mode lumineux' : 'Mode sombre'),
              ),
              if(widget.email==null)  const PopupMenuItem(
                value: 5,
                child: Text('Signaler un problème'),
              ),
              if(widget.email==null)  const PopupMenuItem(
                value: 6,
                child: Text('Déconnexion'),
              ),
            ],
            onSelected: (value) async {
              if (value == 1) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EmployeeStatisticsPerRanges(employeeId: employee.id,)
                    ));

              } else if (value == 2) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const MonCompte()));
              } else if (value == 3) {
              } else if (value == 4) {

                await Provider.of<AppSettings>(context, listen: false).setDarkMode(
                  !Provider.of<AppSettings>(context, listen: false).isDarkMode,
                );

              } else if (value == 5) {
                // action pour l'option 5
              } else if (value == 6) {
                // action pour l'option 6

                Login().googleSingOut();
                ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                  simple: true,
                  showCloseIcon: false,
                  duration: const Duration(seconds: 5) ,
                  //width: MediaQuery.of(context).size.width-2*10,
                  message:'Vous êtes déconnecté' ,
                ));


                Future.delayed(const Duration(seconds: 3),
                        () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const LoginMenu();
                          }));
                    });

              }
            },
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
          ]
      ),
    ));
  }

  onDayLongPressed(DateTime date) async {

log.d('The day is long pressed');

    if(utils.isWeekend(date)){
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: false,
        duration: const Duration(seconds: 5) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:'Weekend' ,
      ));

    }

     if(
     (!utils.isWeekend(date))&&
        (date.isBefore(today)||date.isAtSameMomentAs(today))
    ) {

       log.d('Yes inside');

       log.d('The employee id is: ${employee.id}');
      String? presenceId = await PresenceDB().getPresenceId(date, employee.id);
log.d('Presence id retrieved successfully');
      Presence myPresence = await PresenceDB().getPresenceById(presenceId!);



      if(myPresence.status==EStatus.absent) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
          simple: true,
          showCloseIcon: false,
          duration: const Duration(seconds: 5) ,
          //width: MediaQuery.of(context).size.width-2*10,
          message:'Absent' ,
        ));

      }
else {
  Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              PresenceDetails(presence: myPresence, nEntryTime: employee.entryTime,
                nExitTime: employee.exitTime,),
        ),
      );
}
    }
  }
}
