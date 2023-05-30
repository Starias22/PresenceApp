import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/new_back/firestore/employee_db.dart';
import 'package:presence_app/backend/services/admin_manager.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/frontend/screens/mesStatistiques.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/frontend/screens/login.dart';
import 'package:presence_app/utils.dart';

import '../../backend/services/login.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool isSignedInWithEmail = false;
  String? email;

  String text(){
    //if it's an employee that's logged in
    if(Login().isSignedIn() &&!Login().isSignedInWithPassword()) {

      return 'Mes statistiques';
    } else  if(!Login().isSignedIn()) {
      return 'Connexion Google';
    }
    return '';
  }

  late String action;
  User? user;



  bool loginInProcess = false;

  Future<void> sign() async {
    String message;
    int loginCode;
    setState(() {
      loginInProcess = true;
    });
    loginCode = await Login().googleSignIn();



    switch (loginCode) {
      case popupClosedByUser:
        message =
            "La pop up a été fermée avant la finalisation de l'authentification Google";
        break;
      case success:
        email=FirebaseAuth.instance.currentUser!.email;

        log.d('email of the employee');

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

    log.d(message);
    ToastUtils.showToast(context, message, 3);
    if (loginCode == success) {

      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return MesStatistiques(email: email!,);
      }));
    }

    else {
      setState(() {
        loginInProcess = false; // Arrêter l'animation du cercle de progression
      });
    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PresenceApp",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
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

               if(!Login().isSignedIn()||Login().isSignedInWithPassword())
                 const PopupMenuItem(
                  value: 1,
                  child: Text('Administrateur'),
                ),
                 if(!Login().isSignedIn()||!Login().isSignedInWithPassword())  PopupMenuItem(

                  value: 2,

                  child: Text(text()),
                ),
                if(Login().isSignedIn()) const PopupMenuItem(

                  value: 3,

                  child: Text('Déconnexion'),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {


                  if(Login().isSignedInWithPassword()) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return const  StatistiquesForServices();
                        }));
                  }


                  else {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const Authentification();
                  }));
                  }
                } else if (value == 2) {

              if(Login().isSignedIn()) {
                String? email = FirebaseAuth.instance.currentUser!.email;
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return  MesStatistiques(email: email!,);
                    }));

              }
              else {
                sign();
              }
                }
                else if (value == 3) {
                  await  Login().signOut();
                  setState(() {

                  });
                  ToastUtils.showToast(context, 'Vous êtes déconnecté', 3);
                }

                setState(() {

                });

              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 10,
                  color: Colors.blueGrey.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "You're welcome",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontStyle: FontStyle.italic,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).size.height / 7,
                      width: MediaQuery.of(context).size.width / 3.5,
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Image.asset(
                            'assets/images/imsp1.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),

                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Coucou! Bienvenue dans votre application de suivi de présence ...",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  //SizedBox(height: 10,),

                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Touchez le capteur d'empreintes !",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 30,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  //ArrowAnimation(),

                  Icon(
                    Icons.arrow_right_alt,
                    size: 200,
                    color: Colors.deepPurple.shade800,
                  ),

                  loginInProcess
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child:(!Login().isSignedIn())||(!Login().isSignedInWithPassword()) ?
                            ElevatedButton(
                              onPressed: ()  {

    if(Login().isSignedIn()) {
      email=FirebaseAuth.instance.currentUser!.email;
      log.d('email of the employee: $email');
    Navigator.push(context,
    MaterialPageRoute(builder: (BuildContext context) {
    return MesStatistiques(email: email!,);
    }));

    }
    else {
    sign();
    }

                              },
                              child:  Text(text(),
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 20),
                              )):Container(),
                        )
                ],
              )
            ],
          ))
        ],
      ),
    );
  }
}
