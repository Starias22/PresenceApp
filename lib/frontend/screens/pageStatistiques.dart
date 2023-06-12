import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/firebase/firestore/data_service.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/frontend/screens/afficherAdmins.dart';
import 'package:presence_app/frontend/screens/listeEmployes.dart';
import 'package:presence_app/frontend/screens/pageConges.dart';
import 'package:presence_app/frontend/screens/pageServices.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';
import 'package:provider/provider.dart';
import '../widgets/StatistiquesCard.dart';
import '../widgets/cardTabbar.dart';
import 'adminCompte.dart';
import 'register_admin.dart';

class StatistiquesForServices extends StatefulWidget {
  const StatistiquesForServices({Key? key}) : super(key: key);

  @override
  State<StatistiquesForServices> createState() =>
      _StatistiquesForServicesState();
}

class _StatistiquesForServicesState extends State<StatistiquesForServices> {

  bool dataLoading = true;

  int _selectedIndex = 0;
  int ind=0;

  List<String> tabBars = ['Présences', 'Retards', 'Abscences'];
  List<DataService> chartData = [];
  List<DataService> chartDataAff = [];


  void _etat(int index) async {
    chartDataAff = chartData;
    ind=index;

  }

  @override
  void initState() {
    super.initState();
    data().then((x) {

      if(mounted) {
        setState(() {
        chartData = x;
        dataLoading = false;
      });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);
    return DefaultTabController(
      length: tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Statistiques",
            style: TextStyle(
              fontSize: 20,
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
                const PopupMenuItem(
                  value: 1,
                  child: Text('Employés'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Admins'),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text('Services'),
                ),const PopupMenuItem(
                  value: 4,
                  child: Text('Congés'),
                ),

                const PopupMenuItem(
                  value: 5,
                  child: Text('Créer un compte employé'),
                ),
                const PopupMenuItem(
                  value: 6,
                  child: Text('Créer un compte admin'),
                ),
                const PopupMenuItem(
                  value: 7,
                  child: Text('Mon compte'),
                ),
                 PopupMenuItem(
                  value: 8,
                  child: Text(appSettings.isDarkMode ? 'Mode lumineux' : 'Mode sombre'),
                ),
                const PopupMenuItem(
                  value: 9,
                  child: Text('Langue'),
                ),
                const PopupMenuItem(
                  value: 10,
                  child: Text('Déconnexion'),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  if ((await EmployeeDB().getAllEmployees()).isEmpty) {
                    ToastUtils.showToast(
                        context, 'Aucun employé enregistré', 3);
                    return;
                  }
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AfficherEmployes()));
                } else if (value == 2) {
                  // action pour l'option 2

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AfficherAdmins()));

                }
                else if (value == 3) {
                  // action pour l'option 2

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LesServices()));

                }
                else if (value == 4) {
                  // action pour l'option 2

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PageConges()));

                }
                else if (value == 5) {
                  String email=FirebaseAuth.instance.currentUser!.email!;
                 String adminId= (await AdminDB().getAdminIdByEmail(email))!;
                if(!(await AdminDB().getAdminById(adminId)).isSuper){
                  ToastUtils.showToast(context, 'Seul le super admin peut créer des employés', 3);
                  return;

                }
                  if ((await ServiceDB().getAllServices()).isEmpty) {

                    ToastUtils.showToast(context, 'Aucun service enregistré', 3);
                    return;
                  }
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterEmployee()));
                } else if (value == 6) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterAdmin()));
                } else if (value == 7) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const AdminCompte()));
                } else if (value == 8) {
                  await Provider.of<AppSettings>(context, listen: false).setDarkMode(
                      !Provider.of<AppSettings>(context, listen: false).isDarkMode, );

                }
                else if (value == 9) {

                }
                else if (value == 10) {

                  await Login().signOut();
                  ToastUtils.showToast(context, 'Vous êtes déconnecté', 3);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Welcome()));
                }
              },
            )
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: Colors.white,
              title: Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: TabBar(
                  //controller: _tabController,
                  tabs: List.generate(tabBars.length, (index) {
                    if (_selectedIndex == index) {
                      return CustomTab(
                        text: tabBars[index],
                        isSelected: true,
                      );
                    } else {
                      return CustomTab(text: tabBars[index]);
                    }
                  }),
                  isScrollable: true,
                  onTap: (index) {
                    print("tap");
                    setState(() {
                      _selectedIndex = index;
                      _etat(_selectedIndex);
                    });
                  },
                  indicatorColor: Colors.blueGrey.shade50,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (dataLoading) // Show circular progress indicator if data is loading
                    const Center(child: CircularProgressIndicator())
                  else StatistiquesCard(chartData: chartData,index: ind,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

