import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/esp32.dart';

import 'package:presence_app/frontend/screens/login_menu.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
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
  final GlobalKey<ScaffoldMessengerState>
  _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

  Timer?  dataFetchTimer;



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


  Future<void> getData()
  async {

    String message;
    //there is no internet connection
    if (await Connectivity().checkConnectivity()

        == ConnectivityResult.none) {
      
      connectionStatusOff=false;
      //log.d('There is no internet connection');
      //if there were no internet connection
      if(noNetworkConnection) {
        taskCompleted=true;
        return ;
      }
      //else there were network connection


        message = "Aucune connexion internet";

        if(nextPage) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ToastUtils.showToast(context, message,24*3600 );


        noNetworkConnection=true;
        taskCompleted=true;
        return;

    }
    

    log.d('There is internet connection');
    //if there were no internet connection
    if(noNetworkConnection) {
      message = "Connexion internet rétablie !";
      noNetworkConnection=false;

      //if(nextPage) return;

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ToastUtils.showToast(context, message, 3 );
      
    }


      data=await ESP32().receiveData();


    if(data==espConnectionFailed&&connectionStatusOff==false) {

      log.d('esp failed');
      connected=false;
      message = "Connexion non reussie avec le micrôtrolleur!";

      if(nextPage) return;


      ToastUtils.showToast(context, message,24*3600 );


      connectionStatusOff=true;
      taskCompleted=true;
      return;

    }

     if (1 <= data && data <= 127) {

      var employee = await EmployeeDB()
          .getEmployeeByFingerprintId(data);

      if (employee == null) {
        ToastUtils.showToast(context, 'Vous êtes un intru', 3);
        taskCompleted=true;
        return;
      }

      var before=DateTime.now();
      int code = await PresenceDB().handleEmployeeAction(data);
      var after=DateTime.now();
      var duration=after.difference(before);
      log.d('duration: $duration');

      ToastUtils.showToast(context, '${employee.gender == 'M' ? 'Monsieur' : 'Madame'}'
          ' ${employee.firstname}'
          ' ${employee.lastname}: ${getMessage(code)}', 3);
      taskCompleted=true;
      return;

    }

    else if(data==150)  {
      log.d('data... $data');
      //if not already connected
      if (!connected) {
        connectionStatusOff = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        message = "Connexion reussie avec le micrôtrolleur!";

        ToastUtils.showToast(context, message, 5);
        connected = true;
      }

    }
    else if (data == 151) {
      message =
      "Employé non reconnue! Veuillez reessayer!";
      ToastUtils.showToast(context, message, 3);
    }
    taskCompleted=true;
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
      return "Sortie marquée avec succès";
    }
    if(code==entryMarkedSuccessfully){
      return "Entrée marqué avec succès";
    }

    if(code==desireToExitBeforeEntryTime){
      return "Sortie marquée avant heure d'entrée' officiel";
    }
    if(code==desireToExitEarly){
      return "Sortie marquée avant heure de sortie officiel";
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
                     return const AdminLogin();
                    // return const FingerprintPage();
                  }
                  ));
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
