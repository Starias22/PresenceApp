import 'package:flutter/material.dart';


import '../../backend/models/employe.dart';
import '../../backend/models/employee.dart';

class CompteCard extends StatelessWidget {
  Employee employee;

   CompteCard({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: Text("Compte",
                    style: TextStyle(
                        fontSize: 45
                    ),
                  ),
                  elevation: 10,
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
              Row(
                children: [
                  Icon(Icons.person_pin),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
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
                          child: Text(employee.getLname(),
                            style: TextStyle(
                                fontSize: 15
                            ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(employee.getFname(),
                            style: TextStyle(
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
                  child: Row(
                    children: [
                      Icon(Icons.perm_identity),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Modifier le nom",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue
                          ),),
                      )
                    ],
                  ),

                  onTap: (){
                    print("On m'a appuyé");
                  },
                ),
              )
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
                      child: Text(employee.getEmail(),
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
                            style: TextStyle(
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
