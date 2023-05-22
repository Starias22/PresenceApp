import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/bridge/login.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

import '../../backend/models/admin.dart';

class CompteCard extends StatelessWidget {
  

  Admin admin ;
  CompteCard({Key? key, required this.admin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String? email = currentUser?.email;
    admin.setEmail(email!);
    return ListView(
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 10,
                  child: Text(
                    "Compte",
                    style: TextStyle(fontSize: 45),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                    child: Text(
                        "Mettez à jour vos informations pour assurer la sécurité de votre compte"))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.person_pin),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Informations personnelles et de compte",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            admin.getLname(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            admin.getFname(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  child: const Row(
                    children: [
                      Icon(Icons.perm_identity),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Modifier le nom",
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    print("On m'a appuyé");
                  },
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.contacts),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Coordonnées",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.email),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        admin.getEmail(),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

             
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.security),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Mot de passe et sécurité",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  child: const Row(
                    children: [
                      Icon(Icons.key),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Changer le mot de passe",
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    log.d("On m'a appuyé");

                   var code= await LoginController.forgottenPassword(admin.getEmail());
                  String message;
                                switch (code) {
                                 
                                  case success:
                                    message =
                                        'Un email de réinitialisation de mot de passe a été envoyé à cette adresse';
                                    break;
                                  default:
                                    log.e(code);
                                    message = 'An error occured';
                                    break;
                                }

                                log.d(message);
                                ToastUtils.showToast(context, message, 3);
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
