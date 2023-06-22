// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/frontend/screens/adminCompte.dart';
import 'package:presence_app/frontend/screens/admins_list.dart';
import 'package:presence_app/frontend/screens/employees_list.dart';
import 'package:presence_app/frontend/screens/pageConges.dart';
import 'package:presence_app/frontend/screens/pageServices.dart';
import 'package:presence_app/frontend/screens/presence_report.dart';
import 'package:presence_app/frontend/screens/presence_statistics.dart';
import 'package:presence_app/frontend/screens/register_admin.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late double width1;

  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);
    width1 = MediaQuery.of(context).size.width*4/5;

    return Theme(
        data: appSettings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
    child: Scaffold(
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height/13.5,
            decoration: const BoxDecoration(
              //shape: BoxShape.circle,
              color: Color(0xFF0020FF),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  PopupMenuButton(
                    icon: const Icon(Icons.menu, color: Colors.white,),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            const Text('Employés'),
                            PopupMenuButton(
                                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 1,
                                    child: Text('Créer un compte employé'),
                                  ),
                                  const PopupMenuItem(
                                    value: 2,
                                    child: Text('Liste des employés'),
                                  ),
                                  const PopupMenuItem(
                                    value: 3,
                                    child: Text('Rapport de présence'),
                                  ),
                                  const PopupMenuItem(
                                    value: 4,
                                    child: Text('Statistiques de présence'),
                                  ),
                                ],
                              onSelected: (value){
                                if(value == 1){

                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                        return const RegisterEmployee();
                                      })
                                  );
                                }
                                else if(value == 2){

                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                        return const AfficherEmployes();
                                      })
                                  );
                                }
                                else if(value == 3){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                        return const EmployeePresenceReport();
                                      })
                                  );
                                }
                                else if(value == 4){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                        return const EmployeePresenceStatistics();
                                      })
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            const Text('Admins'),
                            PopupMenuButton(
                                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 1,
                                    child: Text('Créer un compte admin'),
                                  ),
                                  const PopupMenuItem(
                                    value: 2,
                                    child: Text('Liste des admins'),
                                  ),
                                ],
                              onSelected: (value){
                                if(value == 1){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                        return const RegisterAdmin();
                                      })
                                  );
                                } else
                                if(value == 2){

                                  Navigator.push(context,
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                        return const AfficherAdmins();
                                      })
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 3,
                        child: Text('Congés'),
                      ),
                      const PopupMenuItem(
                        value: 4,
                        child: Text('Services'),
                      ),
                    ],
                    onSelected: (value){
                      if(value == 3){
                        Navigator.push(context,
                            MaterialPageRoute(builder:
                                (BuildContext context) {
                              return const PageConges();
                            }));
                      } else
                      if(value == 4){
                        Navigator.push(context,
                            MaterialPageRoute(builder:
                                (BuildContext context) {
                              return const LesServices();
                            })
                        );
                      }
                    },
                  ),

                  Text("PresenceApp",
                    style: GoogleFonts.arizonia(
                      color: Colors.white,
                      fontSize: 25
                    ),
                  ),

                  GestureDetector(
                    onTap: (){

                      // Navigator.push(context,
                      //     MaterialPageRoute(builder:
                      //         (BuildContext context) {
                      //       return const StatistiquesForServices();
                      //     })
                      // );
                    },
                    child: const CircleAvatar(

                      backgroundImage: AssetImage("assets/images/profile.png"),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "logout") {
                        // Handle déconnexion option

                        await Login().googleSingOut();
                        ToastUtils.showToast(context, 'Vous êtes déconnecté',3);
                        Future.delayed(const Duration(seconds: 3),
                                () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(

                                      builder: (context) => const WelcomeImsp()));
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const WelcomeImsp();
                                  }));
                            });


                      }
                      else if (value == "handle") {

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  const AdminCompte()));
                      }

                      else if (value == "dark") {

                        await Provider.of<AppSettings>(context, listen: false)
                            .setDarkMode(
                          !Provider.of<AppSettings>(context, listen: false).
                          isDarkMode,
                        );

                      }
                      else if (value == "language") {

                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>  const MonCompte()));
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

                      const PopupMenuItem<String>(
                        value: "handle",
                        child: Text("Mon compte"),
                      ),
                      PopupMenuItem<String>(
                        value: "dark",
                        child: Text(appSettings.isDarkMode ? 'Mode lumineux' : 'Mode sombre'),
                      ),
                      const PopupMenuItem<String>(
                        value: "language",
                        child: Text("Langue"),
                      ),
                      const PopupMenuItem<String>(
                        value: "logout",
                        child: Text("Déconnexion"),
                      ),
                    ],
                  )
                ],
              ),
            ),

          ),

           Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Bienvenue !",
                      style: GoogleFonts.pinyonScript(
                        fontSize: 35,
                      ),
                    ),
                  ),
                  Text("PresenceApp à votre service...",
                    style: GoogleFonts.tangerine(
                      fontSize: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Avec PresenceApp, surveillez de près les présences de vos employés...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vollkorn(
                        fontSize: 25,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*4/5,
                      child: GestureDetector(
                        onTap: (){
                          showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(50, 370, 0, 0),
                            items: [
                              const PopupMenuItem(
                                value: 1,
                                child: Text('Créer un compte employé'),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                child: Text('Liste des employés'),
                              ),
                              const PopupMenuItem(
                                value: 3,
                                child: Text('Rapport de présence'),
                              ),
                              const PopupMenuItem(
                                value: 4,
                                child: Text('Statistiques de présence'),
                              ),
                            ],
                            elevation: 10,
                          ).then((value){
                            if(value == 1){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const RegisterEmployee();
                                  })
                              );
                            } else
                            if(value == 2){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const AfficherEmployes();
                                  })
                              );
                            } else
                            if(value == 3){

                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const EmployeePresenceReport();
                                  })
                              );
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF0020FF),
                          ),
                          // Définir le style et la forme du bouton ici
                          width: MediaQuery.of(context).size.width*4/5,
                          height: 36,

                            child: const Center(
                              child: Text(
                                'Gestion des employés',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        )
                        ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 35),
                    child: SizedBox(
                      child: GestureDetector(
                        onTap: (){
                          showMenu(
                              context: context,
                              position: const RelativeRect.fromLTRB(50, 450, 0, 0),
                              items: [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('Créer un compte admin'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Liste des admins'),
                                ),
                              ],
                          ).then((value){
                            if(value == 1){

                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const RegisterAdmin();
                                  }));
                            } else
                            if(value == 2){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const AfficherAdmins();
                                  }));
                            }
                          });
                        },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF0020FF),
                            ),
                            // Définir le style et la forme du bouton ici
                            width: MediaQuery.of(context).size.width*4/5,
                            height: 36,

                            child: const Center(
                              child: Text(
                                'Gestion des admins',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 35),
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
                          Navigator.push(context,MaterialPageRoute(
                              builder: (BuildContext context) {return const PageConges();}
                          ));
                        },
                        child: const Text("Geston des congés"),
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
                          Navigator.push(context,
                              MaterialPageRoute(builder:
                                  (BuildContext context) {
                                return const LesServices();
                              }));
                        },
                        child: const Text("Gestions des services"),
                      ),
                    ),
                  ),
                ],
              )
          )
        ],
      )),
    );
  }
}
