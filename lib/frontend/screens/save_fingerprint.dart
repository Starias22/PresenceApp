import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/mesStatistiques.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';


class SaveFingerprint extends StatefulWidget {
  const SaveFingerprint({Key? key}) : super(key: key);

  @override
  State<SaveFingerprint> createState() => _SaveFingerprintState();
}

class _SaveFingerprintState extends State<SaveFingerprint> {
  @override
  void initState() {
    super.initState();
    _textEditingController.text = ''; // Initialisez le texte avec une valeur par défaut
  }

  final TextEditingController _textEditingController = TextEditingController();
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
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextFormField(

                controller: _textEditingController,

                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                validator: (String? v) {
                  if (v != null && v.isNotEmpty) {
                    return null;
                  }
                  return "Entrez le(s) prenom(s) de l'employé";
                },
                onSaved: (String? v) {
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(

              onPressed: () async {
                String inputText = _textEditingController.text;

                String message;
                int uniqueCode;
                bool v;
                try {
                  log.i('input:$inputText');
                  uniqueCode = int.parse(inputText);


                  log.i('Unique code: $uniqueCode');
                }
                catch (error){
                  uniqueCode=1;
                  log.i('error: Unique code: $uniqueCode');
                }
                String? employeeId = await EmployeeDB()
                    .getEmployeeIdByUniqueCode(uniqueCode);
                if (employeeId == null) {
                  message = "Code incorrect";
                  ToastUtils.showToast(context, message, 3);

                  do {
                    v=await ESP32().sendData(
                        'incorrectCode');
                  }while(!v);

                }
                else {
                  message = 'Code correct! Maintenez  votre doigt sur le capteur pour enregistrement';
                  ToastUtils.showToast(context, message, 3);

                  log.d('Still');


                  if(!await ESP32().sendData('correctCode')){
                    log.d('Connection failed');
                    ToastUtils.showToast(context, connectionError, 3);
                    return;

                  }

                  ///int data=await  ESP32().receiveData();

                        int fingerprintId = await ESP32()
                            .receiveData();

                        if (fingerprintId == espConnectionFailed) {
                          ToastUtils.showToast(context, connectionError, 3);
                          return;
                        }
                        if (1<=fingerprintId&&fingerprintId<=115) {
                          // ToastUtils.showToast(context,
                          //     "Empreinte capturée. Replacez le même doigt pour valider l'enregistrement",
                          //     3);
                          if(!await ESP32().sendData('On'))
                            {
                              ToastUtils.showToast(context, connectionError, 3);
                              return;
                            }
                          int fingerprintId2=await ESP32().receiveData();
                          if (fingerprintId2 == espConnectionFailed) {
                            ToastUtils.showToast(context, connectionError, 3);
                            return;
                          }
                          if(fingerprintId2==fingerprintId){
                            EmployeeDB().updateFingerprintId(employeeId,
                                fingerprintId);
                            message = "Empreinte enregistrée avec succès";

                            ToastUtils.showToast(context, message, 3);
                            //Navigator.pop(context);
                            Future.delayed(const Duration(seconds: 3),
                                    () {
                                  Navigator.pop(context);
                                });
                          }
                          else{
                            message = "Echec de l'enregistrement. Veuillez reprendre le processus";
                            ToastUtils.showToast(context, message, 3);

                          }

                        }
                      }

                }
              ,
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
