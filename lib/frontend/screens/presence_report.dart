// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
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
  String selectedStartDate='DD/MM/YYY';
  DateTime today = DateTime.now();

  late String selectedEndDate;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
        required DateTime firstDate,
        DatePickerMode initialDatePickerMode=DatePickerMode.day}) async {

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog
          (title: "Sélection de date",
            message: "Continuer pour sélectionner la date",
            context: context);
      },
    );

    return await  showDatePicker(context: context,
      locale: const Locale('fr'),
      initialDate:initialDate ,
      //replace by the date when the company installed the app
      firstDate: firstDate,
      lastDate:today,
      currentDate: today,
      initialDatePickerMode: initialDatePickerMode,
    );

  }
  Future<void> retrieve() async {
    var x=await utils.localTime();
    setState(() {
      today=x;
      start=today;
      setSelectedDates(date: today);
    });
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

void setSelectedDates({required DateTime date}){

      setState(() {
        if( reportType==ReportType.monthly) {
          start=today;
          selectedStartDate=utils.getMonthAndYear(date);
        }
        else if( reportType==ReportType.annual) {
          start=date;
          selectedStartDate=date.year.toString();
        }
        else if( reportType==ReportType.weekly) {
          start= utils.getWeeksMonday(date);
          selectedStartDate=utils.frenchFormatDate(start);
        }
        else //daily  periodic
            {

              end=start=date;
          selectedStartDate=utils.frenchFormatDate(date);
          //for periodic
          selectedEndDate=utils.frenchFormatDate(date);
        }

      });

}
  @override
  void initState() {
    super.initState();
    retrieve();
    _getValue();
  }

  @override
  Widget build(BuildContext context) {



    return SafeArea(
        child: Scaffold(
            appBar: AppBar(

              backgroundColor: appBarColor,
              centerTitle: true,
              title: const Text(
                "Rapport de présence",
                // style: TextStyle(
                //   fontSize: 23,
                // ),
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

                                onChanged: (val) {
                                  setState(() {
                                    _valueChanged = val!;

                                    if(_valueChanged=='Tous') {
                                      services=null;
                                    }
                                    else {

                                      // services ??= [];
                                      //
                                      // if(!services!.contains(_valueChanged))
                                      // {
                                      //   services!.add(_valueChanged);
                                      // }

                                      services = [];
                                      services!.add(_valueChanged);

                                    }

                                    log.d('Services list: $services');

                                  });

                                },
                                validator: (String? v) {

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
                                      log.d('Report type $reportType');
                                    setSelectedDates(date: today);
                                    });

                                  });

                                  }
                                  ,
                                validator: (String? v) {
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
                                  onSelectDate: () async {

                                    selectedDateOrNull= await selectDate

                                    //replace by the date when the company installed the app
                                      (initialDate: today, firstDate: DateTime(2023,1,1));
                                    if(selectedDateOrNull==null)
                                    {
                                      show();

                                    }
                                    else {
                                      start=selectedDateOrNull!;
                                      setState(() {
                                        selectedStartDate=utils.frenchFormatDate(start);
                                      });
                                      log.d('The selected date: $start');

                                    }
                                  },),
                                const SizedBox(height: 12,),
                                DateActionContainer(title: 'Fin',
                                  selectedDate: selectedEndDate,
                                  onSelectDate: () async {

                                    selectedDateOrNull= await selectDate

                                    //replace by the date when the company installed the app
                                      (
                                        initialDate: today, firstDate: DateTime(2023,1,1));
                                    if(selectedDateOrNull==null)
                                    {
                                      show();

                                    }
                                    else
                                    {
                                      end=selectedDateOrNull!;
                                     setSelectedDates(date: end!);
                                    }

                                    log.d('The selected date: $end');

                                  },),
                              ],
                              )
                                  :DateActionContainer(
                                title: getTitle(),
                                selectedDate: selectedStartDate,
                                onSelectDate:
                                    () async {

                                  selectedDateOrNull= await selectDate
                                  //replace by the date when the company installed the app
                                    (initialDate: today,
                                      firstDate: DateTime(2023,1,1)
                                  );
                                  if(selectedDateOrNull==null)
                                  {
                                    show();
                                  }
                                  else
                                  {
                                    start=selectedDateOrNull!;
                                    setSelectedDates(date: start);
                                  }
                                  log.d('The selected date: $start');
                                    },
                              ),
                              const SizedBox(height: 10,),

                              operationInProcess?
                              const CircularProgressIndicator()
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
                                        (reportType: reportType,
                                          status:
                                          status==null?['late','present']
                                              :[utils.str(status)],
                                          groupByService: groupByService,
                                          start:  start,end: end,
                                          services: services
                                      );

                                     log.d('The report: $report');

                                      Map<String?,List<PresenceRecord>>
                                      presenceRowsByService={};
                                      List<DateTime> targetDates=[];

                                      await Future.forEach
                                        (report.entries, (entry) async {
                                        final serviceNameOrNull = entry.key;
                                        final presences = entry.value;
                                        final presenceRows = <PresenceRecord>[];
                                        for (var presence in presences) {
                                          if(!targetDates.contains(presence.date)) {
                                            targetDates.add(presence.date);
                                          }
                                          final employee = await EmployeeDB().getEmployeeById(presence.employeeId);
                                          final presenceRow = PresenceRecord
                                            (employee: employee, presence: presence);
                                          presenceRows.add(presenceRow);
                                        }
                                        presenceRowsByService[serviceNameOrNull] = presenceRows;
                                      });
                                      log.d('the Number of concerned services:${presenceRowsByService.length}');



                                      var presenceReport=PresenceReport
                                        ( date: utils.formatDateTime(today),
                                          status: status,
                                          reportPeriodType: reportType,
                                          services: services,
                                          presenceRowsByService: presenceRowsByService,
                                          groupByService: groupByService,
                                          start: start,
                                          end: end);
                                      log.d('the Number of concerned services:${presenceReport.presenceRowsByService.length}');

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


                                      List<PresenceReport> presenceReportByDate=[];

                                      log.d('List of target dates: $targetDates');

                                   presenceReportByDate= presenceReport.groupByDate(targetDates);
                                      log.d('the Number of concerned services:${presenceReport.presenceRowsByService.length}');
                                      log.d('List of report by date: $presenceReportByDate');



                                   log.d('${presenceReportByDate[0].presenceRowsByService}');
                                      log.d('Start PDF generating');
                                      await ReportPdf().createAndDownloadOrOpenPdf( presenceReportByDate,targetDates);
                                      setState(() {
                                        operationInProcess=false;
                                      });

                                    },
                                    child:const Text('Générer'),
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
