// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/frontend/widgets/employee_card.dart';
import 'package:presence_app/frontend/widgets/custom_tab_bar.dart';
import 'package:presence_app/utils.dart';

class EmployeesList extends StatefulWidget {

  final Holiday? holiday;
   const EmployeesList({Key? key,

     this.holiday
  }) : super(key: key);

  @override
  State<EmployeesList> createState() => _EmployeesListState();
}

class _EmployeesListState extends State<EmployeesList> {
  List<String> tabBars = ["Tous", 'Présents', 'Retards', 'Absents', 'Sorties'];
  int _selectedIndex = 0;
  late String pictureDownloadUrl;


  late List<Employee> employees = [];
  late List<Employee> employeesAff = [];
  bool holidayCreationInProgress=false;
  List<String> selectedEmployeesIds = []; // Add this line

  @override
  void initState() {
    super.initState();
    retrieve();
  }


  Future<void> retrieve() async {
    var x = await EmployeeDB().getAllEmployees();


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

          actions: [
            if(widget.holiday!=null&&holidayCreationInProgress)
              const CircularProgressIndicator()

             else if(widget.holiday!=null&&!holidayCreationInProgress)
               IconButton(
                  onPressed: () async {
                    DateTime now=await utils.localTime();
                    widget.holiday!.creationDate=now;
                    widget.holiday!.lastUpdateDate=now;

                    if(selectedEmployeesIds.isEmpty&&
                        widget.holiday!.employeesIds!=null)
                      {
                        ScaffoldMessenger.of(context).showSnackBar
                          (const SnackBar(
                          content: Text("Aucun employé sélectionné"),
                          duration: Duration(seconds: 3),
                        ));
                        return;
                      }
                    setState(() {
                      holidayCreationInProgress=true;
                    });
                    if(employees.length==selectedEmployeesIds.length) {
                      widget.holiday!.employeesIds=null;
                    }

                    if(widget.holiday!.employeesIds==null)
                      {
                      }

                    else{
                      widget.holiday?.employeesIds=selectedEmployeesIds;

                    }
                    setState(() {
                      holidayCreationInProgress=false;
                    });
                    await HolidayDB().create(widget.holiday!);

                      ScaffoldMessenger.of(context).showSnackBar
                        (const SnackBar(
                        content: Text("Congé créé avec succès"),
                        duration: Duration(seconds: 3),
                      ));

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminHomePage(
                                )
                        )
                    );






                  },
                  icon: const Icon(Icons.holiday_village))

          ],
          backgroundColor: appBarColor,
          centerTitle: true,
          title:  Text(
            widget.holiday!=null?"Sélection des employés": "Liste des employés",
            style: const TextStyle(
              fontSize: appBarTextFontSize,
            ),

          ),
        ),
        body:
        CustomScrollView(
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
                          EmployeeCard(
                            forHoliday: widget.holiday!=null,
                            isChecked:
                            widget.holiday!=null&& widget.holiday!.employeesIds==null,
                              employee: employeesAff[index],

                            onEmployeeChecked:widget.holiday==null?null:
                       (employee, isChecked) {

                                if (isChecked) {
                                  selectedEmployeesIds.add(employee.id);
                                } else {
                                  selectedEmployeesIds.remove(employee.id);
                                }

                            },
                          )
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
