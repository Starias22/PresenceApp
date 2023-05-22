import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/employe.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/bridge/list_employee.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/widgets/afficherEmployeCard.dart';
import 'package:presence_app/utils.dart';

import '../widgets/cardTabbar.dart';

class AfficherEmployes extends StatefulWidget {
  const AfficherEmployes({Key? key}) : super(key: key);

  @override
  State<AfficherEmployes> createState() => _AfficherEmployesState();
}

class _AfficherEmployesState extends State<AfficherEmployes> {
  List<String> tabBars = ["Tous", 'Présents', 'Retards', 'Absents', 'Sorties'];
  int _selectedIndex = 0;
  final List<Employe> _employes = employes;

  List<Employe> employesAff = employes;
  late List<Employee> employees = [];
  late List<Employee> employeesAff = [];

  @override
  void initState() {
    super.initState();
    retrieve();
  }

  Future<void> retrieve() async {
    var x = await ListEmployeeController.retrieveEmployees();

    setState((){
      employees=x;
          employeesAff = employees;

    });
  }

  @override
  /*void initState() {
    // TODO: implement initState
    super.initState();
    //FirebaseProduit.getProduits().then((value) {
      setState(() {
        //employes = value;
        employesAff = employes;
      });
    }
  }*/

  void _trier(int index) async {
    employesAff = _employes;
    employeesAff = employees;

    if (index == 0) {
      employesAff = _employes;
      employeesAff = employees;
    } else if (index == 1) {
      var list = _employes.where((e) => e.etat == EtatPresence.present);
      employesAff = list.toList();

      var lst = employees.where((e) => e.getCurrentStatus() == EStatus.present);
      employeesAff = lst.toList();
    } else if (index == 2) {
      var list = _employes.where((e) => e.etat == EtatPresence.retard);
      employesAff = list.toList();

      var lst = employees.where((e) => e.getCurrentStatus() == EStatus.late);
      employeesAff = lst.toList();
    } else if (index == 3) {
      var list = _employes.where((e) => e.etat == EtatPresence.absent);
      employesAff = list.toList();

      var lst = employees.where((e) => e.getCurrentStatus() == EStatus.absent);
      employeesAff = lst.toList();
    } else if (index == 4) {
      var list = _employes.where((e) => e.etat == EtatPresence.sortie);
      employesAff = list.toList();

      var lst = employees.where((e) => e.getCurrentStatus() == EStatus.out);
      employeesAff = lst.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    //retrieve();

    for (var emp in employees) {
      emp.logInformations();
    }

    return DefaultTabController(
      length: tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Liste des employés",
            style: TextStyle(
              fontSize: 23,
            ),
          ),
          leading: IconButton(
              onPressed: () => {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StatistiquesForServices()))
                  },
              icon: const Icon(
                Icons.arrow_back,
              )),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: SearchBar(onChanged: (value) {
                  setState(() {
                    employeesAff = employees
                        .where((employe) => (employe.getFname())
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                }),
              ),
            ),
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
                      _trier(_selectedIndex);
                    });
                  },
                  indicatorColor: Colors.blueGrey.shade50,
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
                    List.generate(employeesAff.length, (int index) {
              return Column(
                children: [
                  InkWell(
                      onTap: () {
                        },
                      child:
                          AfficherEmployeCard(employee: employeesAff[index])),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                    child: Divider(),
                  )
                ],
              );
            }))),
          ],
        ),
      ),
    );
  }
}
