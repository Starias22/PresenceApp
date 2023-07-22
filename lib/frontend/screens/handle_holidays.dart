// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';
import 'package:presence_app/frontend/screens/employees_list.dart';
import 'package:presence_app/frontend/widgets/custom_alert_dialog.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/custom_snack_bar.dart';
import 'package:presence_app/frontend/widgets/date_action_row.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class HandleHolidays extends StatefulWidget {
  final Employee? employee;
  const HandleHolidays({Key? key,
    this.employee}) : super(key: key);

  @override
  State<HandleHolidays> createState() => _HandleHolidaysState();
}

class _HandleHolidaysState extends State<HandleHolidays> {
  DateTime? selectedDate;
  late DateTime today;
  late DateTime start;
  late DateTime end;
  bool startDateChanging=false;
  bool endDateChanging=false;
  DateTime initialDate=DateTime(1970,1,1);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }


  Future<void> selectDate({bool isStartDate=true}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Sélection de date",
          message: "Continuer pour sélectionner la date de"
              " ${isStartDate?'début':'fin'} de congé",
          positiveOption: 'Continuer',
          context: context,

        );
      },
    );

    DateTime lastDate=
    utils.addAYear(isStartDate?today:start);
    selectedDate = await  showDatePicker(context: context,
      locale: const Locale('fr'),
      initialDate:isStartDate? initialDate:start ,
      firstDate: isStartDate? initialDate:start ,
      lastDate:lastDate,
      currentDate: today,
    );
    action(isStartDate);



  }
void updateDateController(bool isStartDate){
  setState(() {
    if(isStartDate) {
      startDateChanging=startDateChanging;
    } else {
      endDateChanging=!endDateChanging;
    }
  });
}

  void updateDate(bool isStartDate){
    setState(() {
      if(isStartDate) {
        start=selectedDate!;
        end=start;
      } else {
        end=selectedDate!;
      }
    });
  }
  void action(bool isStartDate){
    updateDateController(isStartDate);

    if(selectedDate==null){
      ToastUtils.showToast(context, "Date non sélectionnée", 3);
     updateDateController(isStartDate);
      return;
    }
    updateDate(isStartDate);


    //
    // if((await HolidayDB().isHoliday(start))){
    //
    //   ToastUtils.showToast(context, "Cette date de début est définie comme un jour férié ou de congés", 3);
    //
    //   setState(() {
    //     startDateChanging=false;
    //   });
    //   return;
    // }

    updateDateController(isStartDate);

  }
  HolidayType type=HolidayType.holiday;
  String? description;
  List<String>? employeesIds=[];

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> retrieveServices() async {
    items.add(utils.str(HolidayType.holiday));
    items.add(utils.str(HolidayType.permission));
    items.add(utils.str(HolidayType.leave));
    items.add(utils.str(HolidayType.disease));
    items.add(utils.str(HolidayType.vacation));
    items.add(utils.str(HolidayType.other));

    DateTime now=await utils.localTime();
    today=DateTime(now.year,now.month,now.day);
    initialDate=today;

    setState(() {
      start= initialDate;
      end=initialDate;

    });

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
    retrieveServices();



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
                "Gestion des congés",
                style: TextStyle(
                  fontSize:appBarTextFontSize,
                ),
              ),
            ),

            body: initialDate.isAtSameMomentAs(DateTime(1970,1,1))?
            const Center(child: CircularProgressIndicator()):  ListView(
              scrollDirection: Axis.vertical,
              children:  [

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
                              const SizedBox(
                                height: 12,
                              ),

                              DropdownButtonFormField(
                                value: items[0],
                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                validator: (String? v) {
                                  // return null;

                                  if (v != null) {
                                  type=utils.convertHoliday(v);
                                    return null;
                                  }
                                  return "Sélectionnez le type de congé";
                                },
                                onSaved: (val) => setState(() {
                                  // _service = int.parse(_valueSaved);
                                }),
                                decoration: InputDecoration(
                                    labelText: 'Type de congé',
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
                              const SizedBox(height: 12),
                              TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null, // Permet d'avoir plusieurs lignes de texte
                                decoration: InputDecoration(
                                  labelText: 'Description (facultatif)',
                                  hintText: 'Ex: Description du congé',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: const BorderSide(color: Colors.green),
                                  ),
                                ),
                                onChanged: (String value) {
                                description=value;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              DropdownButtonFormField(
                                value: 'no',
                                items: const [
                                  DropdownMenuItem(

                                    value: "yes",
                                    child: Text("Oui"),
                                  ),
                                  DropdownMenuItem(
                                    value: "no",
                                    child: Text("Non"),
                                  ),
                                ],
                                onChanged: (val) {

                                    setState(() => _valueChanged = val!
                                    );


                                    if (_valueChanged=='yes')
                                    {
                                      employeesIds=null;
                                    }
                                    if (_valueChanged=='no')
                                    {
                                      employeesIds=[];
                                    }
                                },
                                onSaved: (val) => setState(() {

                                }),
                                decoration: InputDecoration(
                                    labelText: 'Tous les employés?',
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
                              DateActionRow
                                (
                                  dateChanging: startDateChanging,
                                  title: 'Début',
                                  selectedDate:
                                  utils.frenchFormatDate(
                                  start),
                                  onSelectDate:
                                      () async {
                                    await  selectDate();

                                  }
                              ),
                              const SizedBox(height: 12),
                              DateActionRow
                                (
                                  dateChanging: endDateChanging,
                                  title: 'Fin   ',
                                  selectedDate:
                                  utils.frenchFormatDate(end),
                                  onSelectDate:
                                      () async {
                                    await  selectDate(isStartDate: false);

                                  }
                              ),
                              CustomElevatedButton
                                (
                                  text: 'Suivant',
                                  onPressed: (){

                                    if(start.isAfter(end)){
                                      CustomSnackBar(
                                        duration: const Duration(seconds: 5),
                                          message: 'La date de début ne doit pas être après celle de fin');

                                    }
                                    else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EmployeesList(
                                                  holiday: Holiday(
                                                      employeesIds: employeesIds,
                                                    startDate: start,
                                                    endDate: end,
                                                    type: type,
                                                    description: description,
                                                      creationDate: null,
                                                      lastUpdateDate: null
                                                  ),
                                                  )
                                        )
                                    );
                                    }

                                  })
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
