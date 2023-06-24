// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/presence_report_model/presence_record.dart';
import 'package:presence_app/backend/models/presence_report_model/presence_report.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/pdf.dart';

import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class EmployeePresenceReport extends StatefulWidget {
  const EmployeePresenceReport({Key? key}) : super(key: key);

  @override
  State<EmployeePresenceReport> createState() => _EmployeePresenceReportState();
}

class _EmployeePresenceReportState extends State<EmployeePresenceReport> {
  String startDate='JJ/MM/AAAA';
  bool operationInProcess=false;
  late ReportType reportType=ReportType.daily;
  EStatus? status;
  List<String>? services;
  bool? groupByService;
  late DateTime start;
  DateTime? end;










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

  late String  gender;

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> retrieveServices() async {
    items.addAll(await ServiceDB().getServicesNames());


  }

  late List<String> items = ['Tous' ];
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
    retrieveServices();
    _getValue();
  }

  @override
  Widget build(BuildContext context) {



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
                                value: 'all',
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
                                onChanged: (val) {
                                  setState(() {
                                    _valueChanged = val!;

                                    if(_valueChanged=='all') {
                                      status=null;
                                    } else {
                                      status=utils.convertES(_valueChanged);
                                    }

                                  });
                                },
                                validator: (String? v) {
                                  if(v=='all') {
                                    status=null;
                                  } else {
                                    status=utils.convertES(v!);
                                  }
                                  return null;


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
                                value: 'Tous',
                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                validator: (String? v) {
                                  if(v=='Tous') {
                                    services=null;
                                  } else {

                                    // services ??= [];
                                    // services?.add(v!);

                                    //for the moment consider a single service
                                    services!.removeAt(0);
                                    services!.add(v!);
                                  }
                                  return null;


                                },
                                onSaved: (val) => setState(() {

                                }),
                                decoration: InputDecoration(
                                    labelText: 'Service',
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
                                value: 'daily',
                                items:  const [
                                  DropdownMenuItem(
                                    value: "daily",
                                    child: Text("Journalier"),
                                  ),
                                  DropdownMenuItem(
                                    value: "weekly",
                                    child: Text("hebdomadaire"),
                                  ),
                                  DropdownMenuItem(
                                    value: "monthly",
                                    child: Text("Mensuel"),
                                  ),
                                  DropdownMenuItem(
                                    value: "annual",
                                    child: Text("Annuel"),
                                  ),
                                  DropdownMenuItem(
                                    value: "periodic",
                                    child: Text("Autre période"),
                                  ),

                                ],

                                onChanged: (val) {
                                  setState(() {
                                    _valueChanged = val!;
                                    reportType = utils.convert(val);
                                    log.d( 'Report type : $reportType');// Update the reportType based on the selected value
                                  });
                                },
                                validator: (String? v) {
                                  //reportType=utils.convert(v!);
                                  return null;
                                },
                                onSaved: (val) => setState(() {

                                }),
                                decoration: InputDecoration(
                                    labelText: "Type de rapport",
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

                              operationInProcess?  const CircularProgressIndicator()
                                  :   ElevatedButton(
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
                                      setState(() {
                                        operationInProcess=true;
                                      });

                                     var report=
                                      await PresenceDB().getPresenceReport
                                        (reportType: reportType,groupByService: groupByService,
                                          start:  DateTime(2023,6,6),end: end,
                                          services: services
                                      );
                                      if(report=={}){
                                        //empty report
                                        ToastUtils.showToast(context, 'Rapport de présence vide', 3);
                                        return;
                                      }

                                      List<PresenceRecord> presenceRows=[];
                                      PresenceRecord presenceRow;
                                      Employee employee;

                                      Map<String?,List<PresenceRecord>>
                                      presenceRowsByService={};


                                      report.forEach((serviceName, presences)
                                      async {

                                        presenceRows=[];
                                        for(var presence in presences){


                                          employee=await EmployeeDB().
                                          getEmployeeById(presence.employeeId);
                                          presenceRow=PresenceRecord
                                            (employee: employee, presence: presence);
                                          presenceRows.add(presenceRow);

                                        }
                                        presenceRowsByService[serviceName]=presenceRows;

                                      });

                                      var presenceReport=PresenceReport
                                        ( date: '',status: status,
                                          reportPeriodType: reportType,services: services,
                                          presenceRowsByService: presenceRowsByService,
                                          groupByService: groupByService);

                                      await Report().createAndDownloadOrOpenPdf( presenceReport);
                                      setState(() {
                                        operationInProcess=false;
                                      });










                                    },
                                    child:const Text('Télécharger'),
                                  ),

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
