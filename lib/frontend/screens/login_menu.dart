// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/frontend/screens/bottom_nav_bar.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';
import 'package:presence_app/frontend/screens/admin_login.dart';
import 'package:presence_app/utils.dart';

import 'employee_home_page.dart';


class LoginMenu extends StatefulWidget {
  const LoginMenu({Key? key}) : super(key: key);


  @override
  State<LoginMenu> createState() => _LoginMenuState();
}

class _LoginMenuState extends State<LoginMenu> {

  late String login, password;

  // Timer?  dataFetchTimer;
  @override
  void initState() {
    super.initState();
  }



  /*may be:
  both esp32 and the device are not connected to the same network
  wrong ip address provided in the code for the esp32
  */
  final connectionError="Erreur de connexion! Veillez reessayer";
  bool isSignedInWithEmail = false;
  String? email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  void dispose() {
    // Perform cleanup tasks here
    super.dispose();
  }




  bool loginInProcess = false;

  Future<void> googleSignIn() async {


    
      final result = await (Connectivity().checkConnectivity());

      if (result == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
          simple: true,
          showCloseIcon: false,
          duration: const Duration(seconds: 3) ,
          //width: MediaQuery.of(context).size.width-2*10,
          message:'Aucune connexion internet' ,
        ));
        setState(() {
          loginInProcess = false;
        });

        return;
      }


    String message;
    int loginCode;
    
    loginCode = await Login().googleSignIn();



    switch (loginCode) {
      case popupClosedByUser:
        message =
            "La pop up a été fermée avant la finalisation de l'authentification Google";
        break;
      case success:
        email=FirebaseAuth.instance.currentUser!.email;

        if(await EmployeeDB().exists(email!)) {
          message = 'Authentification Google réussie';
        }
        else {
          //new user with wrong email
          message =
          "Adresse email non reconnue! Utilisez l'adresse de votre compte employé";

          Login().googleSingOut();
          Login().deleteCurrentUser();
          loginCode=failure;
        }
        break;
      case networkError:
        message =
            'Erreur de réseau! Vérifiez votre connexion internet et reessayez';
        break;
      default:
        message = 'Erreur inconnue';
        break;
    }

    log.d('Out of switch');
      log.d(message);

log.d(message);

      setState(() {
        loginInProcess = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: false,
        duration: const Duration(seconds: 10) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:message ,
      ));

    if (loginCode == success) {

      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
         return const EmployeeHomePage();


      }));
    }


  }


  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    });


    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height/10,),

              const Text("Connectez-vous !",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height/2,
                child: Center(
                  child: Image.asset('assets/images/blob.png', fit: BoxFit.cover,),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Choisissez votre compte Google",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),


             loginInProcess? 
             const CircularProgressIndicator():
             ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
                  ),
                  onPressed: ()  {
                    log.d('Admin login');

                    if(Login().isSignedIn()) {
                      email=FirebaseAuth.instance.currentUser!.email;

                    }
                    else {

                      setState(() {
                        loginInProcess = true;
                      });

                      googleSignIn();
                    }
                  },
                  child:  const Text("Connexion avec Google",
                    style: TextStyle(
                      //fontSize: 20
                    ),
                  )
              ),

              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text("Cliquez ici si vous êtes administrateur",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                      log.d('Admin login');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return const AdminLogin();
                          }));
                    },
                    child: const Text("Administrateur"),
                  ),
                ),
              )
        ],
      )
        ],
      ),
    );
  }
}
