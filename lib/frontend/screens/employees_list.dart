import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/widgets/afficherEmployeCard.dart';
import 'package:presence_app/frontend/widgets/cardTabbar.dart';

class AfficherEmployes extends StatefulWidget {
  const AfficherEmployes({Key? key}) : super(key: key);

  @override
  State<AfficherEmployes> createState() => _AfficherEmployesState();
}

class _AfficherEmployesState extends State<AfficherEmployes> {
  List<String> tabBars = ["Tous", 'Présents', 'Retards', 'Absents', 'Sorties'];
  int _selectedIndex = 0;
  late String pictureDownloadUrl;


  late List<Employee> employees = [];
  late List<Employee> employeesAff = [];

  @override
  void initState() {
    super.initState();
    retrieve();
  }


  Future<void> retrieve() async {
    var x = await EmployeeDB().getAllEmployees();
    var y=

    setState((){
      employees=x;
          employeesAff = employees;

    });
  }

    void _trier(int index) async {
       if (index == 0) {

      employeesAff = employees;
    } else if (index == 1) {

      var lst = employees.where((e) => e.status == EStatus.present);
      employeesAff = lst.toList();
    } else if (index == 2) {

      var lst = employees.where((e) => e.status ==EStatus.late);
      employeesAff = lst.toList();
    } else if (index == 3) {

      var lst = employees.where((e) => e.status == EStatus.absent);
      employeesAff = lst.toList();
    } else if (index == 4) {

      var lst = employees.where((e) => e.status == EStatus.out);
      employeesAff = lst.toList();
    }
  }




  @override
  Widget build(BuildContext context) {

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
                                const AdminHomePage()))
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
                child: SearchBar(
                  hintText: 'Rechercher par nom, prénom ou service',
                    onChanged: (value) {
                  setState(() {
                    employeesAff = employees
                        .where(
                            (employee) =>
                        (employee.firstname)
                            .toLowerCase()
                            .contains(value.toLowerCase())||
                            (employee.service)
                                .toLowerCase()
                                .contains(value.toLowerCase())||
                            (employee.lastname)
                                .toLowerCase()
                                .contains(value.toLowerCase())

                    )
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
                          AfficherEmployeCard(employee: employeesAff[index])
                  ),
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
