import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/afficherAdmins.dart';
import 'package:presence_app/frontend/screens/listeEmployes.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';
import '../../new_back/firestore/employee_db.dart';
import '../../new_back/firestore/service_db.dart';
import '../../new_back/login.dart';
import '../../new_back/service.dart';
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
    return DefaultTabController(
      length: tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Statistiques",
            style: TextStyle(
              fontSize: 20,
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
                    child: Text('Employés'),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Admins'),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: Text('Créer un compte employé'),
                  ),
                  const PopupMenuItem(
                    value: 4,
                    child: Text('Créer un compte admin'),
                  ),
                  const PopupMenuItem(
                    value: 5,
                    child: Text('Mon compte'),
                  ),
                  const PopupMenuItem(
                    value: 6,
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
                  } else if (value == 3) {
                    if ((await ServiceDB().getAllServices()).isEmpty) {
                      log.e('Aucun service enregistré');
                      ToastUtils.showToast(context, 'Aucun service enregistré', 3);
                      return;
                    }
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterEmployee()));
                  } else if (value == 4) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterAdmin()));
                  } else if (value == 5) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const AdminCompte()));
                  } else if (value == 6) {

                     await Login().signOut();
                    ToastUtils.showToast(context, 'Vous êtes déconnecté', 3);


                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Welcome()));
                  }
                },
              ),
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

