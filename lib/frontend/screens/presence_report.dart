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
import 'package:presence_app/frontend/widgets/alert_dialog.dart';
import 'package:presence_app/frontend/widgets/date_action_widget.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';
import 'package:presence_app/utils.dart';

class EmployeePresenceReport extends StatefulWidget {
  const EmployeePresenceReport({Key? key}) : super(key: key);

  @override
  State<EmployeePresenceReport> createState() => _EmployeePresenceReportState();
}

class _EmployeePresenceReportState extends State<EmployeePresenceReport> {

  bool operationInProcess=false;
  late ReportType reportType=ReportType.daily;
  EStatus? status;
  List<String>? services;
  bool? groupByService;
  late DateTime start;
  DateTime? selectedDateOrNull;
  DateTime? end;
  String selectedStartDate='JJ/MM/AAAA';
  String selectedMonth='Mois';
  String selectedYear='Année';
  String selectedWeek='Semaine';
  final defaultDate='JJ/MM/AAAA';
  late String selectedEndDate;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  DateTime? selectedDate;
  bool canEnrollFingerprint=false;
  late DateTime today;



void selectPeriodLimits(){
//selectDate(initialDate: today);
}
void show({String message="Date  non sélectionnée"}){
  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
    simple: true,
    showCloseIcon: true,
    duration: const Duration(seconds: 3) ,
    //width: MediaQuery.of(context).size.width-2*10,
    message: message,

  ));
}

String getTitle(){
  if(reportType==ReportType.daily) return 'Date';
  if(reportType==ReportType.weekly) return 'Semaine du';
  if(reportType==ReportType.monthly) return 'Mois';
  if(reportType==ReportType.annual) return 'Année';
  return 'Unknown';
}

  Future<DateTime?> selectDate(
      {String name='',
        required DateTime initialDate,
        required DateTime firstDate}) async {

    await showDialog(
      context: context,
      builder: (BuildContext context) {

        return CustomDialog
          (title: "Sélection de date",
            message: "Continuer pour sélectionner la date",
            context: context);

      },
    );

    //selectedDate =
    return await  showDatePicker(context: context,
      locale: const Locale('fr'),
      initialDate:initialDate ,
      //replace by the date when the company installed the app
      firstDate: firstDate,
      lastDate:today,
      currentDate: today,
    );

    //
    // if(selectedDate==null){
    //   ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
    //     simple: true,
    //     showCloseIcon: true,
    //     duration: const Duration(seconds: 3) ,
    //     //width: MediaQuery.of(context).size.width-2*10,
    //     message:"Date de $name non sélectionnée" ,
    //   ));

    // }
    //
    //
    //  start=selectedDate!;

   // return selectedDate;

  }
  Future<void> retrieveServices() async {
    items.addAll(await ServiceDB().getServicesNames());
    today=await utils.localTime();
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
    selectedStartDate=defaultDate;
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

                                    log.d('New status: $status');

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

                                onChanged: (val) {
                                  setState(() {
                                    _valueChanged = val!;

                                    if(_valueChanged=='Tous') {
                                      services=null;
                                    } else {

                                      services ??= [];
                                      services?.add(_valueChanged);

                                      // //for the moment consider a single service
                                      // services!.removeAt(0);
                                      // services!.add(v!);
                                    }

                                    log.d('Services list: $services');

                                  });

                                },
                                validator: (String? v) {
                                  if(v=='Tous') {
                                    services=null;
                                  } else {

                                    services ??= [];
                                    services?.add(v!);

                                    // //for the moment consider a single service
                                    // services!.removeAt(0);
                                    // services!.add(v!);
                                  }

                                  log.d('Services list: $services');
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
                                    child: Text("Hebdomadaire"),
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

                                onChanged: (val) async {
                                  setState(() {
                                    _valueChanged = val!;

                                    setState(() {
                                      reportType = utils.convert(val);
                                    });

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

                              reportType==ReportType.periodic?
                              Column(
                                children: [
                                DateActionContainer(title: 'Début',
                                  selectedDate: selectedStartDate,
                                  onSelectDate: () {  },),
                                const SizedBox(height: 12,),
                                DateActionContainer(title: 'Fin',
                                  selectedDate: selectedEndDate,
                                  onSelectDate: () {  },),
                              ],
                              )
                                  :DateActionContainer(
                                title: getTitle(),
                                selectedDate: selectedStartDate,
                                onSelectDate:
                                    () async {
                                  selectedDateOrNull= await selectDate

                                  //replace by the date when the company installed the app
                                    (initialDate: today, firstDate: DateTime(2023,1,1));
                                  if(selectedDateOrNull==null)
                                  {
                                    show();
                                    setState(() {
                                      selectedStartDate=defaultDate;
                                    });

                                  }
                                  else {
                                    start=selectedDateOrNull!;
                                    setState(() {
                                      selectedStartDate=utils.frenchFormatDate(start);
                                    });

                                  }

                                    },
                              ),
                              const SizedBox(height: 10,),

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
                                          start:  start,end: end,
                                          services: services
                                      );

                                     log.d('The report: $report');
                                      log.d('The length of the report: ${report.length}');



                                      Map<String?,List<PresenceRecord>>
                                      presenceRowsByService={};


                                      await Future.forEach(report.entries, (entry) async {
                                        final serviceNameOrNull = entry.key;
                                        final presences = entry.value;
                                        final presenceRows = <PresenceRecord>[];
                                        for (var presence in presences) {
                                          final employee = await EmployeeDB().getEmployeeById(presence.employeeId);
                                          final presenceRow = PresenceRecord(employee: employee, presence: presence);
                                          presenceRows.add(presenceRow);
                                        }
                                        presenceRowsByService[serviceNameOrNull] = presenceRows;
                                      });


                                      log.d('the Number of concerned services:${presenceRowsByService.length}');



                                      var presenceReport=PresenceReport
                                        ( date: '',status: status,
                                          reportPeriodType: reportType,services: services,
                                          presenceRowsByService: presenceRowsByService,
                                          groupByService: groupByService);

                                      if(presenceReport.isEmpty()){
                                        //empty report

                                        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                                          simple: true,
                                          showCloseIcon: true,
                                          duration: const Duration(seconds: 3) ,
                                          //width: MediaQuery.of(context).size.width-2*10,
                                          message:'Rapport de présence vide' ,
                                        ));
                                        setState(() {
                                          operationInProcess=false;
                                        });

                                        return;
                                      }

                                      log.d('Start PDF generating');

                                      await ReportPdf().createAndDownloadOrOpenPdf( presenceReport);
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
