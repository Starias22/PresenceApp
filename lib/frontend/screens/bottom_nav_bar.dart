import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/pageConges.dart';
import 'package:presence_app/frontend/screens/presence_report.dart';
import 'package:presence_app/frontend/screens/register_admin.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/screens/services_management.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';
import 'package:presence_app/utils.dart';

import 'adminCompte.dart';
import 'admins_list.dart';
import 'employees_list.dart';

/// Flutter code sample for [AppBar].

List<String> titles = <String>[
  'Employés',
  'Admins',
  'Autres',
];

void main() => runApp(const AppBarApp());

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: const AppBarExample(),
    );
  }
}

class AppBarExample extends StatelessWidget {
  const AppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    const int tabsCount = 3;

    return DefaultTabController(
      initialIndex: 1,
      length: tabsCount,
      child: Scaffold(

        appBar: AppBar(
          // centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [

            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                // size: 30,
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                // if(widget.email!=null)
                const PopupMenuItem(
                  value: 1,
                  child: Text('Mon compte'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Langue'),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text('Mode sombre'),
                ),
                const PopupMenuItem(
                  value: 4,
                  child: Text('Déconnexion'),
                ),

              ],
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const AdminAccount()));

                }
                if (value == 2) {


                }if (value == 3) {


                }
                if (value == 4) {
                  await Login().googleSingOut();
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                    simple: true,
                    showCloseIcon: false,
                    duration: const Duration(seconds: 3) ,
                    //width: MediaQuery.of(context).size.width-2*10,
                    message:'Vous êtes déconnecté' ,
                  ));

                  Future.delayed(const Duration(seconds: 3),
                          () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(

                                builder: (context) =>
                                const WelcomeImsp()));
                        Navigator.push(context, MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const WelcomeImsp();
                            }));
                      });

                }


              },
            ),

          ],
          backgroundColor: appBarColor,
          title: const Text('PresenceApp'),

          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 1;
          },
          // The elevation value of the app bar when scroll view has
          // scrolled underneath the app bar.
          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: const Icon(Icons.person),
                text: titles[0],
              ),
              Tab(
                icon: const Icon(Icons.key),
                text: titles[1],
              ),
              Tab(
                icon: const Icon(Icons.brightness_5_sharp),
                text: titles[2],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[

            ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: ListTile(
                    // tileColor: index.isOdd ? oddItemColor : evenItemColor,
                    title: Container(

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
                          const Text("PresenceApp à votre service...",
                            style: TextStyle(fontSize: 20),
                            // style:
                            // GoogleFonts.pinyonScript(
                            //   fontSize: 30,
                            // ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Image.asset(


                              'assets/images/clock1.jpg',
                              width:MediaQuery.of(context).size.width ,
                              height:MediaQuery.of(context).size.height*0.35 ,
                              fit: BoxFit.cover,
                              //width: MediaQuery.of(context).size.width*0.75,
                            ),

                          ),


                         SizedBox(
                    height: MediaQuery.of(context).size.height/30),
                          MenuButton(
                              text: 'Créer un employé',
                              onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder:
                                        (BuildContext context) {
                                      return RegisterEmployee(
                                    employee:
                                         Employee
                                          ( firstname: 'John',
                                            gender: 'M', lastname: 'LOLA',
                                            email: 'email@gmail.com', service:'Direction',
                                            startDate: DateTime(2023,7,10), entryTime: '08:00',
                                            exitTime: '17:00'),

                                      );
                                    })
                                );
                              },
                            width: MediaQuery.of(context).size.width*4/5,
                              ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height/50),
                          MenuButton(
                            text: 'Liste des employés',
                            onPressed: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const AfficherEmployes();
                                  })
                              );
                            },
                            width: MediaQuery.of(context).size.width*4/5,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height/50),
                          MenuButton(
                            text: 'Rapport de présences',
                            onPressed: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder:
                                      (BuildContext context) {
                                    return const EmployeePresenceReport();
                                  })
                              );
                            },
                            width: MediaQuery.of(context).size.width*4/5,
                          ),
                        ],
                      ),
                    )
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: ListTile(
                    // tileColor: index.isOdd ? oddItemColor : evenItemColor,
                      title: Container(

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
                            const Text("PresenceApp à votre service...",
                              style: TextStyle(fontSize: 20),
                              // style:
                              // GoogleFonts.pinyonScript(
                              //   fontSize: 30,
                              // ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Image.asset(
                                'assets/images/admin.jpg',
                                width:MediaQuery.of(context).size.width ,
                                height:MediaQuery.of(context).size.height*0.35 ,
                                fit: BoxFit.cover,
                                //width: MediaQuery.of(context).size.width*0.75,
                              ),

                            ),


                            SizedBox(
                                height: MediaQuery.of(context).size.height/30),
                            MenuButton(
                              text: 'Créer un admin',
                              onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder:
                                        (BuildContext context) {
                                      return const RegisterAdmin();
                                    }));
                              },
                              width: MediaQuery.of(context).size.width*4/5,
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height/50),
                            MenuButton(
                              text: 'Liste des admins',
                              onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder:
                                        (BuildContext context) {
                                      return const AfficherAdmins();
                                    })
                                );
                              },
                              width: MediaQuery.of(context).size.width*4/5,
                            ),
                          ],
                        ),
                      )
                  ),
                );
              },
            ),


            ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: ListTile(
                    // tileColor: index.isOdd ? oddItemColor : evenItemColor,
                      title: Container(

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
                            const Text("PresenceApp à votre service...",
                              style: TextStyle(fontSize: 20),

                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Image.asset(


                                'assets/images/services.jpg',
                                width:MediaQuery.of(context).size.width ,
                                height:MediaQuery.of(context).size.height*0.35 ,
                                fit: BoxFit.cover,
                                //width: MediaQuery.of(context).size.width*0.75,
                              ),

                            ),


                            SizedBox(
                                height: MediaQuery.of(context).size.height/30),
                            MenuButton(
                              text: 'Gérer les congés',
                              onPressed: (){
                                Navigator.push(context,MaterialPageRoute(
                                    builder: (BuildContext context) {return const PageConges();}
                                ));
                              },
                              width: MediaQuery.of(context).size.width*4/5,
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height/50),
                            MenuButton(
                              text: 'Gérer les services',
                              onPressed: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder:
                                        (BuildContext context) {
                                      return const ServicesManagement();
                                    }));
                              },
                              width: MediaQuery.of(context).size.width*4/5,
                            ),

                          ],
                        ),
                      )
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
