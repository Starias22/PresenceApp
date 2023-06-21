// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';

import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class EmployeePresenceReport extends StatefulWidget {
  const EmployeePresenceReport({Key? key}) : super(key: key);

  @override
  State<EmployeePresenceReport> createState() => _EmployeePresenceReportState();
}

class _EmployeePresenceReportState extends State<EmployeePresenceReport> {
  String startDate='JJ/MM/AAAA';










  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  DateTime? selectedDate;
  bool canEnrollFingerprint=false;
  late DateTime today;


  Future<void> selectStartDateAndAchieve(BuildContext context) async {

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sélection de date"),
          content: const Text("Continuer pour sélectionner la date de début de travail de l'employé"),
          actions: <Widget>[
            TextButton(
              child: const Text('Continuer'),
              onPressed: () async {


                Navigator.of(context).pop();


              },
            ),

          ],
        );
      },
    );

    DateTime lastDate=utils.add30Days(today);
    DateTime nextWorkDate=utils.getNextWorkDate(today);


    selectedDate = await  showDatePicker(context: context,

      locale: const Locale('fr'),
      initialDate:nextWorkDate ,
      firstDate: utils.isWeekend(today)?nextWorkDate:today ,
      lastDate:lastDate,
      currentDate: today,
    );

    if(selectedDate==null){



      ToastUtils.showToast(context, "Date de début de travail non sélectionnée", 3);
      return;
    }
    DateTime start=selectedDate!;

    if(utils.isWeekend(start)){

      ToastUtils.showToast(context, "La date de début de travail ne doit pas être un weekend", 3);
      return;
    }


    if((await HolidayDB().isHoliday(start))){

      ToastUtils.showToast(context, "Cettte date de début est définie comme un jour férié ou de congés", 3);
      return;
    }
    setState(() {
      startDate=utils.frenchFormatDate(selectedDate);
    });

    return;










  }

  late String firstname, lastname, email, serviceName, gender, entryTime, exitTime;

  bool fingerprintSaved=false;
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> retrieveServices() async {
    items = await ServiceDB().getServicesNames();
    items.add('Tous');
  }

  late List<String> items = [];
  String _valueChanged = '';
  final _key = GlobalKey<FormState>();

  TextEditingController? _controller;

  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _controller?.text = 'circleValue';
      });
    });
  }


  @override
  void initState() {
    super.initState();

    _getValue();
  }

  @override
  Widget build(BuildContext context) {

    retrieveServices();

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(

              backgroundColor: const Color(0xFF0020FF),
              centerTitle: true,
              title: Text(
                "Rapport de présence",
                style: GoogleFonts.arizonia(
                  fontSize: 25,
                ),
              ),
            ),

            body: ListView(
              scrollDirection: Axis.vertical,
              children: [
                const SizedBox(
                  height: 25,
                ),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _key,
                          child: Column(
                            children: [
                              DropdownButtonFormField(
                                items: const [
                                  DropdownMenuItem(
                                    value: "present",
                                    child: Text("Présent"),
                                  ),
                                  DropdownMenuItem(
                                    value: "late",
                                    child: Text("Retard"),
                                  ),
                                  DropdownMenuItem(
                                    value: "all",
                                    child: Text("Tous"),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                onSaved: (val) => setState(() {
                                  //_service = int.parse(_valueSaved);
                                }),
                                validator: (String? v) {
                                  return null;

                                  // if (v != null) {
                                  //   gender = v;
                                  //   return null;
                                  // }
                                  // return "Sélectionnez le sexe";
                                },
                                decoration: InputDecoration(
                                    labelText: 'Statut',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide:
                                      const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide:
                                      const BorderSide(color: Colors.green),
                                    )),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              DropdownButtonFormField(
                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                validator: (String? v) {
                                  return null;

                                  // if (v != null) {
                                  //   serviceName = v;
                                  //   return null;
                                  // }
                                  // return "Sélectionnez le service";
                                },
                                onSaved: (val) => setState(() {

                                }),
                                decoration: InputDecoration(
                                    labelText: 'Selectionnez le service',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide:
                                      const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide:
                                      const BorderSide(color: Colors.green),
                                    )),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              DropdownButtonFormField(
                                items:  const [
                                  DropdownMenuItem(
                                    value: "daily",
                                    child: Text("Journalier"),
                                  ),
                                  DropdownMenuItem(
                                    value: "week",
                                    child: Text("hebdomadaire"),
                                  ),
                                  DropdownMenuItem(
                                    value: "month",
                                    child: Text("Mensuel"),
                                  ),
                                  DropdownMenuItem(
                                    value: "year",
                                    child: Text("Annuel"),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                validator: (String? v) {
                                  return null;


                                },
                                onSaved: (val) => setState(() {

                                }),
                                decoration: InputDecoration(
                                    labelText: "Selectionnez l'heure d'arrivée",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide:
                                      const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide:
                                      const BorderSide(color: Colors.green),
                                    )),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
                                    ),
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const EmployeePresenceReport())),
                                    child: const Text("Annuler"),
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
                                    ),
                                    onPressed: () async {
                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();
                                      }
                                      else {
                                        return;
                                      }
                                      DateTime now=await utils.localTime();
                                      today=DateTime(now.year,now.month,now.day);

                                      selectStartDateAndAchieve(context);



                                    },
                                    child: const Text('Télécharger'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
