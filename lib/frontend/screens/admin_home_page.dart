// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/frontend/screens/handle_holidays.dart';
import 'package:presence_app/frontend/screens/presence_report.dart';
import 'package:presence_app/frontend/screens/register_admin.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/screens/services_management.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/custom_snack_bar.dart';
import 'package:presence_app/utils.dart';

import 'adminCompte.dart';
import 'admins_list.dart';
import 'employees_list.dart';
import 'attribute_holidays.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<String> titles = <String>[
    'Employés',
    'Admins',
    'Autres',
  ];
  bool? isSuperAdmin ;
Future<void> retrieveMerv() async {
  log.i('Setting all employees attendance for today');
  await PresenceDB().setAllEmployeesAttendancesUntilCurrentDay();

String? email=FirebaseAuth.instance.currentUser?.email;
var x=(await AdminDB().getAdminByEmail(email!)).isSuper;

setState(() {
  isSuperAdmin=x ;
});


}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log.d("####################èèèèèèèèèzezzzz");
    retrieveMerv();
    log.d("####################aaaaaaaaaaaaaaaaaaaaaaaaaa");
  }
  @override
  Widget build(BuildContext context) {
    const int tabsCount = 3;

    return DefaultTabController(
      initialIndex: 1,
      length: tabsCount,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            if (isSuperAdmin!=null)
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
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
                  if(isSuperAdmin!)const PopupMenuItem(
                    value: 4,
                    child: Text("Page d'accueil"),
                  ),
                  const PopupMenuItem(
                    value: 5,
                    child: Text("Déconnexion"),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminAccount(),
                      ),
                    );
                  }
                  if (value == 2) {
                    // Langue selected
                  }
                  if (value == 3) {
                    // Mode sombre selected
                  }
                  if (value == 4) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Welcome(
                          isSuperAdmin: isSuperAdmin!,),
                      ),
                    );
                  }
                  if (value == 5) {
                    await Login().googleSingOut();
                    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                      simple: true,
                      showCloseIcon: false,
                      duration: const Duration(seconds: 3),
                      message: 'Vous êtes déconnecté',
                    ));

                    Future.delayed(const Duration(seconds: 3), () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Welcome(),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const Welcome();
                          },
                        ),
                      );
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
                    title: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Bienvenue !",
                            style: GoogleFonts.pinyonScript(
                              fontSize: 35,
                            ),
                          ),
                        ),
                        const Text(
                          "PresenceApp à votre service...",
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            'assets/images/clock1.jpg',
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 30,
                        ),
                       if(isSuperAdmin==true) MenuButton(
                          text: 'Créer un employé',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return RegisterEmployee(

                                    // employee: Employee(
                                    //   firstname: 'John',
                                    //   gender: 'M',
                                    //   lastname: 'LOLA',
                                    //   email: 'email@gmail.com',
                                    //   service: 'Direction',
                                    //   startDate: DateTime(2023, 7, 10),
                                    //   entryTime: '08:00',
                                    //   exitTime: '17:00',
                                    // ),

                                  );
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 50,
                        ),
                        MenuButton(
                          text: 'Liste des employés',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const EmployeesList();
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 50,
                        ),
                        MenuButton(
                          text: 'Rapport de présences',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const EmployeePresenceReport();
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: ListTile(
                    title: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Bienvenue !",
                            style: GoogleFonts.pinyonScript(
                              fontSize: 35,
                            ),
                          ),
                        ),
                        const Text(
                          "PresenceApp à votre service...",
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            'assets/images/admin.jpg',
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 30,
                        ),
                        MenuButton(
                          text: 'Créer un admin',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const RegisterAdmin();
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 50,
                        ),
                        MenuButton(
                          text: 'Liste des admins',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const AdminsList();
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: ListTile(
                    title: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            "Bienvenue !",
                            style: GoogleFonts.pinyonScript(
                              fontSize: 35,
                            ),
                          ),
                        ),
                        const Text(
                          "PresenceApp à votre service...",
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Image.asset(
                            'assets/images/services.jpg',
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.35,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 30,
                        ),
                        MenuButton(
                          text: 'Gérer les congés',
                          onPressed: () {


                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const HandleHolidays();
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 50,
                        ),
                        MenuButton(
                          text: 'Gérer les services',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const ServicesManagement();
                                },
                              ),
                            );
                          },
                          width: MediaQuery.of(context).size.width * 4 / 5,
                        ),
                      ],
                    ),
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
