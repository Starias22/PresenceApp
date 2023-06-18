import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/employee.dart';

import 'package:presence_app/frontend/screens/pageModifierEmployer.dart';


class CompteCard extends StatelessWidget {
  Employee employee;

 /* String getFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');

    // Check if a dot exists and it is not the last character
    if (dotIndex != -1 && dotIndex < fileName.length - 1) {
      // Extract the substring starting from the dot index + 1
      return fileName.substring(dotIndex + 1);
    }

  }*/

   CompteCard({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
                  child: Text("Compte",
                    style: TextStyle(
                        fontSize: 45
                    ),
                  ),
                ),

                SizedBox(height: 5,),

                Center(
                    child: Text("Mettez à jour vos informations pour assurer la sécurité de votre compte")
                )
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
                    child: Text("Informations personnelles et de compte",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),),
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
                          child: Text(employee.lastname,
                            style: const TextStyle(
                                fontSize: 15
                            ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(employee.firstname,
                            style: const TextStyle(
                                fontSize: 15
                            ),
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
                        child: Text("Modifier le nom",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue
                          ),),
                      ),
                    ],
                  ),


                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return FormulaireModifierEmploye(employee: employee,);
                      }),
                    );

                  },
                ),
              ),
              // Commentaire : Ajouter un InkWell pour "Modifier ma photo"
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  child: const Row(
                    children: [
                      Icon(Icons.photo_camera),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Modifier ma photo",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Commentaire : Gérer le clic sur "Modifier ma photo"
                  },
                ),
              ),

            ],
          ),
        ),

        Padding(padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.contacts),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Coordonnées",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.email),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(employee.email,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue
                        ),),
                    ),
                  ],
                ),
              ),

              /*Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.call),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(employe.email,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue
                        ),),
                    ),
                  ],
                ),
              )*/
            ],
          ),
        ),

          /*Padding(padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.security),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Mot de passe et sécurité",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.key),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Changer le mot de passe",
                            style: TfforextStyle(
                                fontSize: 20,
                                color: Colors.blue
                            ),),
                        ),
                      ],
                    ),

                    onTap: (){
                      print("On m'a appuyé");
                    },
                  ),
                )
              ],
            ),
          )*/
      ],
    );
  }
}
