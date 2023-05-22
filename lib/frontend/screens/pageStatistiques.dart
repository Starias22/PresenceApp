import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/services/admin_manager.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/backend/services/service_manager.dart';
import 'package:presence_app/bridge/register_employee_controller.dart';
import 'package:presence_app/frontend/screens/afficherAdmins.dart';
import 'package:presence_app/frontend/screens/listeEmployes.dart';
import 'package:presence_app/frontend/screens/monCompte.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

import '../../backend/geo/modele/service.dart';
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
  //with SingleTickerProviderStateMixin;

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  int _selectedIndex = 0;
  //late TabController _tabController;
  List<String> tabBars = ['Présences', 'Retards', 'Abscences'];
  List<DataService> chartData = [];
  List<DataService> chartDataAff = [];
  final myKey = GlobalKey<DropdownSearchState<MultiLevelString>>();
  final List<MultiLevelString> myItems = [
    MultiLevelString(level: "Comptabilité"),
    MultiLevelString(level: "Direction"),
    MultiLevelString(level: "Secrétariat administratif"),
    MultiLevelString(level: "Service de coorpération"),
    MultiLevelString(level: "Service scolarité"),
  ];

  void _etat(int index) async {
    chartDataAff = chartData;
    if (index == 0) {
      chartDataAff = chartData;
    } else if (index == 1) {
      chartDataAff = chartData;
    } else if (index == 2) {
      chartDataAff = chartData;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      chartData = data();
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
                    if (await EmployeeManager().getCount() == 0) {
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
                    if (await ServiceManager().getCount() == 0) {
                      log.e('Aucun service enregistré');
                      showToast('Aucun service enregistré');
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
                            builder: (context) => const AdminCompte()));
                  } else if (value == 6) {
                    // action pour l'option 5
                    var out = await AdminManager().signOut();

                    log.d('Vous êtes déconnecté:$out');

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
                  StatistiquesCard(chartData: chartData),
                  //Text("Je suis a la recherche d'idée, vais y arriver"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiLevelString {
  final String level;
  final List<MultiLevelString> subLevel;
  bool isExpanded;

  MultiLevelString({
    this.level = "",
    this.subLevel = const [],
    this.isExpanded = false,
  });

  MultiLevelString copy({
    String? level,
    List<MultiLevelString>? subLevel,
    bool? isExpanded,
  }) =>
      MultiLevelString(
        level: level ?? this.level,
        subLevel: subLevel ?? this.subLevel,
        isExpanded: isExpanded ?? this.isExpanded,
      );

  @override
  String toString() => level;
}
