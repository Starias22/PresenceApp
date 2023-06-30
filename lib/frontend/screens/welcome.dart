// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/login_menu.dart';
import 'package:presence_app/frontend/screens/presence_report.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';
import 'package:presence_app/main.dart';
import 'package:presence_app/utils.dart';

class WelcomeImsp extends StatefulWidget {

  const WelcomeImsp({Key? key}) : super(key: key);


  @override
  State<WelcomeImsp> createState() => _WelcomeImspState();
}

class _WelcomeImspState extends State<WelcomeImsp>with RouteAware {

  @override
  void didPopNext() {

    setState(() {

    nextPage=false;
      //  connected=false;
      connectionStatusOff=false;
      //  //data=espConnectionFailed;
      taskCompleted=true;
    noNetworkConnection=false;


    });
    super.didPopNext();

  }

  /*may be:
  both esp32 and the device are not connected to the same network
  wrong ip address provided in the code for the esp32
  */
  final connectionError="Erreur de connexion! Veillez reessayer";

  bool nextPage=false;
  bool connected=false;
  bool connectionStatusOff=false;
  int data=espConnectionFailed;
  bool taskCompleted=true;
  bool noNetworkConnection=false;
  bool noSuchEmployee=false;

  Timer?  dataFetchTimer;
  late Image employeePicture;
  bool pictureDownloadInProcess=false;
  late DateTime now;

  late Employee employee;
  



  @override



  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();

      startDataFetching();

  }


  @override
  void didChangeDependencies() {

    super.didChangeDependencies();

  }



  void startDataFetching() {


    const duration = Duration(seconds: 3);
    dataFetchTimer = Timer.periodic(duration, (_)  async {
      if(nextPage) return;

      if(taskCompleted) {
        taskCompleted=false;
        await getData();
      }
    });

  }
  //
  // Future<int> assureDataChanged(int fingerprintId,int val ) async {
  //   int data = fingerprintId ;
  //   int cpt = 0;
  //
  //   Future<int> fetchData() async {
  //     data = await ESP32().receiveData();
  //
  //     if (cpt == 10) {
  //
  //       return 152;
  //     }
  //
  //     if (data ==val) {
  //       log.d('Data changed');
  //       return data;
  //     }
  //     else {
  //       cpt++;
  //       await Future.delayed(const Duration(seconds: 1));
  //       return await fetchData();
  //     }
  //
  //   }
  //
  //   return await fetchData();
  // }
  //

  Future<void> getData()
  async {
    log.d('Getting data');

     String message;

    //there is no internet connection
    if (await Connectivity().checkConnectivity()

        == ConnectivityResult.none) {

      connectionStatusOff=false;
      //if there were no internet connection
      if(noNetworkConnection) {
        taskCompleted=true;
        return ;
      }

      //else there were network connection


        message = "Aucune connexion internet";

        if(nextPage) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();


      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        showCloseIcon: true,
        duration: const Duration(days: 1) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:message ,
      ));




        noNetworkConnection=true;
        taskCompleted=true;
        return;

    }

    //if there were no internet connection
    if(noNetworkConnection) {
      message = "Connexion internet rétablie!";
      noNetworkConnection=false;

      if(nextPage) return;

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: false,
        duration: const Duration(seconds: 3) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:message ,
      ));

    }


      data=await ESP32().receiveData();
     if (data == 151) {
    noSuchEmployee=true;
    message =
    "Employé non reconnue! Veuillez reessayer!";
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
    simple: true,
    showCloseIcon: false,
    duration: const Duration(seconds: 3) ,
    //width: MediaQuery.of(context).size.width-2*10,
    message:message ,
    ));
    log.d('33333');

    // int x=await assureDataChanged(data, 150);
    //
    // if(x==152) {
    //   taskCompleted=true;
    // }
    taskCompleted=true;
    return;


    }
    noSuchEmployee=true;


    if(data==espConnectionFailed&&connectionStatusOff==false) {

      log.d('esp failed');
      connected=false;
      message = "Connexion non reussie avec le micrôtrolleur!";

      if(nextPage) return;


      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: true,
        duration: const Duration(days: 1) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:message ,
      ));


      connectionStatusOff=true;
      taskCompleted=true;
      return;

    }

     if (1 <= data && data <= 127) {

       log.d('That is a fingerprint id');
       Employee? nullableEmployee = await EmployeeDB()
          .getEmployeeByFingerprintId(data);


      if (nullableEmployee == null) {
        log.d('INTRU');
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
          simple: true,
          showCloseIcon: true,
          duration: const Duration(seconds: 1) ,
          //width: MediaQuery.of(context).size.width-2*10,
          message:'Vous êtes un intru' ,
        ));

        // log.d('11111');
        // int x=await assureDataChanged(data, 150);
        // if(x==152) {
        //   taskCompleted=true;
        // }
        //
        return;
      }

       now=await utils.localTime();
      employee=nullableEmployee;

      int code = await PresenceDB().handleEmployeeAction(data,now);
      //int code=entryMarkedSuccessfully;


       employeePicture=
       employee.pictureDownloadUrl==null?Image.asset('assets/images/imsp1.png') :
       Image.network(
         employee.pictureDownloadUrl!,
         loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
           if (loadingProgress == null) {

             return child;
           }

           final totalBytes = loadingProgress.expectedTotalBytes;
           final bytesLoaded = loadingProgress.cumulativeBytesLoaded;

           // Calculate the download progress as a percentage
           final progress = (totalBytes != null)
               ? (bytesLoaded / totalBytes * 100).toInt()
               : null;

           // Display the progress or any other custom widget
           return Center(
             child: CircularProgressIndicator(
               value: progress != null ? progress / 100 : null,
             ),
           );
         },
       );



       ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
         showCloseIcon: true,
         //width: MediaQuery.of(context).size.width-2*10,
         message:'${employee.gender == 'M' ? 'Monsieur' : 'Madame'}'
             ' ${employee.firstname}'
             ' ${employee.lastname}: ${getMessage(code)}' ,
         image: employeePicture  ,
       ));
//
// log.d('22222');
//   int x=await assureDataChanged(data, 150);
//   if(x==150) {
    taskCompleted=true;
  // }
      return;

    }

    else if(data==150)  {

      log.d('data... $data');
      //if not already connected
      if (!connected) {
        connectionStatusOff = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        message = "Connexion reussie avec le micrôtrolleur!";


        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
          simple: true,
          showCloseIcon: false,
          duration: const Duration(seconds: 5) ,
          //width: MediaQuery.of(context).size.width-2*10,
          message:message ,
        ));

        connected = true;

      }

      //log.d('The end');
      taskCompleted=true;

    }


    //log.d('The end of the function');


  }


  String getMessage(int code){
    if(code==isWeekend){
      return "Aujourdh'ui est un weekend";

    }
    if(code==inHoliday){
      return "Congé, permission ou jour férié auparavent activé";
    }
    if(code==exitAlreadyMarked){
      return "Sortie déjà marquée";
    }
    if(code==exitMarkedSuccessfully){
      return "Sortie marquée avec succès(${utils.formatTime(now)})! Veuillez enlever votre doigt du capteur!";
    }
    if(code==entryMarkedSuccessfully){
      return "Entrée marquée avec succès(${utils.formatTime(now)})! Veuillez enlever votre doigt du capteur!";
    }

    if(code==desireToExitBeforeEntryTime){
      return "Sortie marquée(${utils.formatTime(now)}) avant heure d'entrée officielle(${employee.entryTime})";
    }
    if(code==desireToExitEarly){
      return "Sortie marquée(${utils.formatTime(now)}) avant heure de sortie officielle(${employee.exitTime})";
    }
    return 'Inconnu';

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: (){
                  nextPage=true;

                  Navigator.push(context,MaterialPageRoute(
                  builder: (BuildContext context) {
                   //return const AdminLogin();
                    return const EmployeePresenceReport();
                  }));
    },


                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    child: Text("Passer"),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height/20,),
                Text("Bienvenue",
                  style: GoogleFonts.pinyonScript(
                    color: Colors.black,
                    fontSize: 34,
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("IMSP",
                      style: GoogleFonts.tangerine(
                        color: const Color(0xFF0020FF),
                        fontSize: 30,
                        fontWeight: FontWeight.w900
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(" Dangbo",
                        style: GoogleFonts.smokum(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("PresenceApp",
                    style: GoogleFonts.alexBrush(
                      color: const Color(0xFF0020FF),
                      fontSize: 35,
                      //fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Votre application qui vous permet de marquer et de suivre les presences...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tangerine(
                      fontSize: 25
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Center(
                    child: Image.asset('assets/images/people.jpg', fit: BoxFit.cover,
                      //width: MediaQuery.of(context).size.width*0.75,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*4/5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
                      ),
                        onPressed: (){
                        nextPage=true;
                          Navigator.push(context,MaterialPageRoute(
                              builder: (BuildContext context) {return const AdminLogin();}
                          ));
                        },
                        child: const Text("Commencer"),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
