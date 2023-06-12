import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/esp32.dart';


import 'package:presence_app/frontend/screens/mesStatistiques.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/screens/save_fingerprint.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/frontend/screens/login.dart';
import 'package:presence_app/frontend/widgets/wrapperEmployee.dart';
import 'package:presence_app/utils.dart';


class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);


  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  final _key = GlobalKey<FormState>();
  late String login, password;
  bool _isSecret = false;

  Timer?  dataFetchTimer;
  @override
  void initState() {
    super.initState();
    startDataFetching();
  }

  Future<void> startDataFetching() async {

    const duration = Duration(seconds: 5);
     dataFetchTimer = Timer.periodic(duration, (_) {
      getData();
    });
  }

  /*may be:
  both esp32 and the device are not connected to the same network
  wrong ip address provided in the code for the esp32
  */
  final connectionError="Erreur de connexion! Veillez reessayer";
  bool isSignedInWithEmail = false;
  String? email;

  Future<void> getData()
  async {
    int data;
    String message;

      data=await ESP32().receiveData();

      log.d('Data*****: $data');
      if(data==espConnectionFailed) {
        message = "Connexion non reussie avec le micrôtrolleur!";
        //ToastUtils.showToast(context, message, 5);
      }

     else if(1<=data&&data<=127){
        var employeeId = await EmployeeDB()
            .getEmployeeIdByFingerprintId(data);
        if (employeeId == null) {
          ToastUtils.showToast(context, 'Vous êtes un intru', 3);
          return;
        }

        int code=await  PresenceDB().handleEmployeeAction(data);
        var employee=await EmployeeDB().getEmployeeById(employeeId);
        String civ=employee.gender=='M'?'Monsieur':'Madame';
        ToastUtils.showToast(context, '$civ ${employee.firstname}'
            ' ${employee.lastname}: ${getMessage(code)}', 3);
      }

      else if(data==151){
        message =
        "Employé non reconnue! Veuillez reessayer!";
        ToastUtils.showToast(context, message, 3);
      }
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
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  void dispose() {
    // Perform cleanup tasks here
    super.dispose();
  }


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
      extendBodyBehindAppBar: true,
      /*appBar: AppBar(
        title: const Text(
          "PresenceApp",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
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
              const PopupMenuItem(
                value: 4,
                child: Text("Pointer"),
              ),
              const PopupMenuItem(
                value: 5,
                child: Text("Enregistrer empreinte"),
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
              else if (value == 5) {

                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const SaveFingerprint();
                    }));
                            }

              setState(() {

              });

            },
          )
        ],
      ),*/
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

              Container(
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

              /*loginInProcess
                  ? const Center( child: CircularProgressIndicator(),) :
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child:(!Login().isSignedIn())||(!Login().isSignedInWithPassword()) ?
                SizedBox(
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
                      onPressed: ()  {

                        if(Login().isSignedIn()) {
                          email=FirebaseAuth.instance.currentUser!.email;
                          log.d('email of the employee: $email');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (BuildContext context) {
                                return const Wrapper();
                              }));
                        }
                        else {sign();}
                      },
                      child:  const Text("Connexion avec Google",
                        style: TextStyle(
                            //fontSize: 20
                        ),
                      )),
                ):Container(),
              ),*/

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

                    if(Login().isSignedIn()) {
                      email=FirebaseAuth.instance.currentUser!.email;
                      /*log.d('email of the employee: $email');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return const Wrapper();
                          }));*/
                    }
                    else {sign();}
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

              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _key,
                    child: Column(
                      children: [
                        TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (String? v) {
                              if (v != null && EmailValidator.validate(v)) {
                                return null;
                              } else {
                                return "Login invalide";
                              }
                            },
                            onSaved: (String? v) {
                              login = v!;
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 3),
                                filled: true,
                              fillColor: const Color(0xFFEEF0FF),
                                label: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Login:'),
                                ),
                                hintText: "Ex: admin@gmail.com",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                  const BorderSide(color: Colors.red),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                  const BorderSide(color: Colors.green),
                                ))),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => setState(() {}),
                            obscureText: _isSecret,
                            validator: (String? v) {
                              if (v != null && v.length >= 6) {
                                return null;
                              } else {
                                return "Mot de passe invalide";
                              }
                            },
                            onSaved: (String? v) {
                              password = v!;
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFEEF0FF),
                                contentPadding: const EdgeInsets.symmetric(vertical: 3),
                                suffixIcon: InkWell(
                                  onTap: () => setState(() {
                                    _isSecret = !_isSecret;
                                  }),
                                  child: Icon(!_isSecret
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                                label: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Password:'),
                                ),
                                hintText: "Ex: ............",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                  const BorderSide(color: Colors.red),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                  const BorderSide(color: Colors.green),
                                ))),
                      ],
                    )
                ),
              ),*/
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return const Authentification();
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
