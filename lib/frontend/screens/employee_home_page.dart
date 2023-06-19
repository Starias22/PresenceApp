// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/presence.dart';
import 'package:presence_app/frontend/screens/presence_details.dart';
import 'package:presence_app/frontend/widgets/calendrierCard.dart';
import 'package:presence_app/frontend/widgets/employee_home_page_card.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({Key? key}) : super(key: key);

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

Future<String> getDownloadURL(String fileName) async {
  try {
    return await FirebaseStorage.instance
        .ref()
        .child(fileName)
        .getDownloadURL();
  } catch (e) {
    return "";
  }
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {

  Future<String>? imageDownloadURL;
  String? email=FirebaseAuth.instance.currentUser!.email;
  String? filename;
  late Employee employee;

  late Presence presenceDoc;
  late DateTime startDate;
  bool isLoading = true;
  late DateTime now,today;
  late DateTime nEntryTime,nExitTime;
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

      x = await PresenceDB().getMonthReport(employee.id, today);
    }


    setState(() {

      _events = x;
      startDate=y;
      isLoading=false;

    });
  }






  @override
  void initState() {
    super.initState();
    retrieveReport();
    retrieve().then((_) {

      imageDownloadURL = getDownloadURL(filename!);
      retrieveReport();
    });



  }

  Future<void> getImageName() async {

    final items =
        (await FirebaseStorage.instance.ref().listAll()).items;

    filename= items.where((item) => item.name.
    startsWith(RegExp('^${employee.id}'))).toList()[0].name;

  }
  onDayLongPressed(DateTime date) async {

    if(utils.isWeekend(date)){
      ToastUtils.showToast(context, 'Weekend', 3);
    }

    if((!utils.isWeekend(date))&&(date.isBefore(today)||date.isAtSameMomentAs(today))) {
      String? presenceId = await PresenceDB().getPresenceId(date, employee.id);

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
  Future<void> retrieve() async {

    employee= await EmployeeDB().getEmployeeByEmail(email!);

    await getImageName();
    setState(() {
      imageDownloadURL = getDownloadURL(filename!);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String>(
          future: imageDownloadURL,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
            isLoading = false; // Set isLoading to false when data is available
            // Rest of your code


              return CustomScrollView(
                slivers: [

                  HomePageCard(
                    employee:employee ,
                    imageDownloadURL: snapshot.data!,
                  ),
                   SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text(
                            'Votre texte ici',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Un autre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CalendrierCard(
                            events: _events,
                            onDayLongPressed: onDayLongPressed,
                            onCalendarChanged: onCalendarChanged,
                            minSelectedDate: DateTime.now(),
                          ),


                        ],
                      ),

                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
