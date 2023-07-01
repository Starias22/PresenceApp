import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';
import 'package:presence_app/utils.dart';

class PageConges extends StatefulWidget {
  const PageConges({super.key});

  @override
  _PageCongesState createState() => _PageCongesState();
}

class _PageCongesState extends State<PageConges> {
  List<Employee> employees = [];
  List<String> names = [];
Future<void> retrieve() async {
  employees=await EmployeeDB().getAllEmployees();
  log.d('Length of the list***: ${employees.length}');
  names=employees.map((employee) =>
  '${employee.firstname} ${employee.lastname}').toList();
}

  List<bool> checkedList = List<bool>.generate(5, (index) => false);
  bool selectAll = false;
  List<Holiday> employesEnConge = [];
  late DateTime dateDC;
  late DateTime dateFC;
  List<int> days = List<int>.generate(31, (index) => index + 1);
  List<int> months = List<int>.generate(12, (index) => index + 1);
  List<int> years = List<int>.generate(100, (index) => DateTime.now().year + index);

  late DateTime selectedDate = DateTime.now();
  late int selectedDay = selectedDate.day;
  late int selectedMonth = selectedDate.month;
  late int selectedYear = selectedDate.year;

  late DateTime selectedDateF = DateTime.now();
  late int selectedDayF = selectedDateF.day;
  late int selectedMonthF = selectedDateF.month;
  late int selectedYearF = selectedDateF.year;

  @override
  void initState() {
    super.initState();
    retrieve();

    selectedDate = DateTime.now();
    selectedDay = selectedDate.day;
    selectedMonth = selectedDate.month;
    selectedYear = selectedDate.year;

    selectedDateF = DateTime.now();
    selectedDayF = selectedDateF.day;
    selectedMonthF = selectedDateF.month;
    selectedYearF = selectedDateF.year;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleDateSelection() {
    selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
    selectedDateF = DateTime(selectedYearF, selectedMonthF, selectedDayF);
    print('Date débuit congé : $selectedDate');
    print('Date fin congé : $selectedDateF');
  }

  void _saveConge() {
    int j = 0;

    print("On m'a exécuité");
    if(employesEnConge.isEmpty)
    {
      print("Avant la boucle for la liste est vide");
    }

    for (int i = 0; i < employees.length; i++) {
      if (checkedList[i]) {
        employesEnConge[j].id = employees[i].id;
        employesEnConge[j].startDate = dateDC;
        employesEnConge[j].endDate = dateFC;
        j++;
      }
    }

    if(employesEnConge.isEmpty)
    {
      print("Après la boucle for la liste est toujours vide");
    }
    else {
      print("La liste n'est pas vide après la boucle");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text('Gestion des congés',
        // style: TextStyle(
        //   fontSize: 23
        // ),
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Date débuit congé : "),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: selectedDay,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDay = newValue!;
                        });
                      },
                      items: days.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: selectedMonth,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMonth = newValue!;
                        });
                      },
                      items: months.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: selectedYear,
                      onChanged: (newValue) {
                        setState(() {
                          selectedYear = newValue!;
                        });
                      },
                      items: years.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Date fin congé : "),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<int>(
                      value: selectedDayF,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDayF = newValue!;
                        });
                      },
                      items: days.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: selectedMonthF,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMonthF = newValue!;
                        });
                      },
                      items: months.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: selectedYearF,
                      onChanged: (newValue) {
                        setState(() {
                          selectedYearF = newValue!;
                        });
                      },
                      items: years.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //Text('Tout sélectionner'),
                Align(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    value: selectAll,
                    onChanged: (value) {
                      setState(() {
                        selectAll = value!;
                        checkedList = List<bool>.filled(names.length, value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: names.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(names[index]),
                  value: checkedList[index],
                  onChanged: (value) {
                    setState(() {
                      checkedList[index] = value!;
                    });
                  },
                );
              },
            ),
          ),

          //SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      checkedList = List<bool>.filled(names.length, false);
                      selectAll = false;
                    });
                  },
                  child: const Text("Annuler"),
                ),

                ElevatedButton(
                    onPressed: (){
                      _saveConge();
                      _handleDateSelection();
                      if (employesEnConge.isEmpty) {
                        _showSnackBar("Aucun employé n'a été sélectionné !");
                      }
                      else{

                      }
                      setState(() {
                        checkedList = List<bool>.filled(names.length, false);
                        selectAll = false;
                      });
                    },
                    child: const Text("Enregistrer"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
