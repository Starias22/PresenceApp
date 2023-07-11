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

late Presence presenceDoc;
  late Employee employee;
  late DateTime startDate;
  late String email;
  bool isLoading = true;
  late DateTime now,today;
  bool showMenu=false;
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
    setState(() {
      showMenu=true;
    });


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
          style: TextStyle(
            fontSize: appBarTextFontSize,
          ),
        ),
        actions: [
          if(showMenu)
            PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              // size: 30,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              // if(widget.email!=null)
                const PopupMenuItem(
                value: 1,
                child: Text('Statistiques par intervalles'),
              ),

            ],
            onSelected: (value) async {
              if (value == 1) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EmployeeStatisticsPerRanges(
                              employeeId: employee.id,
                              employeeName: '${employee.lastname} '
                                  '${employee.firstname}',
                              startDate: employee.startDate,
                            )
                    ));

               }

            },
          )
        ],
        leading: IconButton(
            onPressed: () => {
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

      String? presenceId = await PresenceDB().getPresenceId(date, employee.id);
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

     else  if(myPresence.status==EStatus.inHoliday) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
          simple: true,
          showCloseIcon: false,
          duration: const Duration(seconds: 5) ,
          //width: MediaQuery.of(context).size.width-2*10,
          message:'En congé' ,
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
