import 'package:flutter/material.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/frontend/screens/mesStatistiques.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/frontend/screens/login.dart';
import 'package:presence_app/utils.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool loginInProcess = false;

  Future<void> sign() async {
    String message;
    int loginCode;
    setState(() {
      loginInProcess = true;
    });
    loginCode = await EmployeeManager().signIn();

    log.d('login code:$loginCode');
    switch (loginCode) {
      case popupClosedByUser:
        message =
            "Vous avez fermé la popup avant la finalisation de l'authentification Google";
        break;
      case accountDeleted:
        message =
            "Votre compte vient d'être supprimé car vous n'êtes plus employé";
        break;
      case networkError:
        message =
            'Erreur de réseau! Vérifiez votre connexion internet et reessayez';
        break;
      case success:
        message = 'Authentification Google réussie';
        break;
      case emailInCorrect:
        message =
            "Adresse email non reconnue! Utilisez l'adresse de votre compte employé";
        break;
      default:
        message = 'Erreur inconnue';
        break;
    }
    //loginInProcess = false;

    log.d(message);
    ToastUtils.showToast(context, message, 3);
    if (loginCode == success)
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return MesStatistiques();
      }));
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
                const PopupMenuItem(
                  value: 1,
                  child: Text('Administrateur'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Mes statistiques'),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  // action pour l'option 1
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return const Authentification();
                  }));
                } else if (value == 2) {
                  // action pour l'option 2
                  sign();
                }
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
                      "Touchez le capteur d'empreinte !",
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
                          child: ElevatedButton(
                              onPressed: () => {sign()},
                              child: const Text(
                                "Mes statistiques",
                                style: TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 20),
                              )),
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
