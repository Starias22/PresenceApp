// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/enroll_fingerprint.dart';
import 'package:presence_app/frontend/widgets/alert_dialog.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/date_action_widget.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class RegisterEmployee extends StatefulWidget {
  Employee? employee;
  RegisterEmployee({Key? key,
  this.employee}) : super(key: key);

  @override
  State<RegisterEmployee> createState() => _RegisterEmployeeState();
}

class _RegisterEmployeeState extends State<RegisterEmployee> {
  DateTime? selectedDate;
  late DateTime today;
   late DateTime start;
  bool dateChanging=false;
  DateTime initialDate=DateTime(1970,1,1);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }


    Future<void> selectDate() async {
      await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Sélection de date",
          message: "Continuer pour sélectionner la date de début de travail de l'employé",
          positiveOption: 'Continuer',
          context: context,

        );
      },
      );

      DateTime lastDate=utils.add30Days(today);
      selectedDate = await  showDatePicker(context: context,

        locale: const Locale('fr'),
        initialDate:initialDate ,
        firstDate: initialDate ,
        lastDate:lastDate,
        currentDate: today,
      );

      setState(() {
        dateChanging=true;
      });

      if(selectedDate==null){
        ToastUtils.showToast(context, "Date de début de travail non sélectionnée", 3);
        setState(() {
          dateChanging=false;
        });
        return;
      }
       start=selectedDate!;

      if(utils.isWeekend(start)){

        ToastUtils.showToast(context, "La date de début de travail ne doit pas être un weekend", 3);
        setState(() {
          dateChanging=false;
        });
        return;
      }


      if((await HolidayDB().isHoliday(start))){

      ToastUtils.showToast(context, "Cette date de début est définie comme un jour férié ou de congés", 3);

      setState(() {
        dateChanging=false;
      });
      return;
      }

      setState(() {
        dateChanging=false;
      });


    }
    //#######################################################################
  Future<void> handleRegisterEmployee(BuildContext context) async {


    int? fingerprintId;

    // if(widget.employee!=null) {
    //   log.d(' is fingerprint id null? ${widget.employee?.fingerprintId==null}');
    // }

     if(widget.employee!=null&&widget.employee!.fingerprintId!=null){
      fingerprintId=widget.employee!.fingerprintId;
    }
    log.d('tHE FINGERPRINTID IS § $fingerprintId');
    log.d('---tHE FINGERPRINTID IS § ${widget.employee?.fingerprintId}');
    widget.employee=Employee
      ( firstname: firstname,
        gender: gender, lastname: lastname,
        email: email, service:serviceName,
        startDate: start, entryTime: entryTime,
        exitTime: exitTime,
    fingerprintId:fingerprintId );




    String message;

    if(await EmployeeDB().exists(widget.employee!.email)){

      message=  'Cette adresse email a été déjà attribuée à un employé';
      ToastUtils.showToast(context, message, 3);
      return;

    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
             EnrollFingerprint(
               employee:widget.employee!,)));


  }

  late String firstname, lastname, email, serviceName, gender, entryTime, exitTime;

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> retrieveServices() async {
    items = await ServiceDB().getServicesNames();
    DateTime now=await utils.localTime();
    today=DateTime(now.year,now.month,now.day);
    initialDate= utils.isWeekend(today)?utils.getNextWorkDate(today):today;

    setState(() {
      start= initialDate;

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
                "Création de compte employé",
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
                              TextFormField(
                                  initialValue: widget.employee?.lastname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,

                                  validator: (String? v) {

                                    if (v != null && v.isNotEmpty) {
                                      lastname = v;
                                      log.d('Value changement');
                                      // widget.employee?.lastname=lastname;
                                      return null;
                                    } else {
                                      return "Entrez le nom de l'employé";
                                    }
                                  },
                                  onSaved: (String? v) {
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Nom:'),
                                      hintText: "Ex: ADOKO",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ))),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                  initialValue: widget.employee?.firstname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    // return null;

                                    if (v != null && v.isNotEmpty) {
                                      firstname = v;
                                      // widget.employee?.firstname=firstname;
                                      return null;
                                    }
                                    return "Entrez le(s) prenom(s) de l'employé";
                                  },
                                  onSaved: (String? v) {
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Prenom(s):'),
                                      hintText: "Ex: John",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ))),
                              const SizedBox(
                                height: 12,
                              ),
                              TextFormField(
                                  initialValue: widget.employee?.email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    // return null;

                                    if (v != null &&
                                        EmailValidator.validate(v)) {
                                      email = v;
                                      widget.employee?.email=email;
                                      return null;
                                    }
                                    return "Email invalide";
                                  },
                                  onSaved: (String? v) {
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Email:'),
                                      hintText: "Ex: employe@gmail.com",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ))),
                              const SizedBox(
                                height: 12,
                              ),
                              DropdownButtonFormField(
                                value: widget.employee?.gender,
                                items: const [
                                  DropdownMenuItem(

                                    value: "M",
                                    child: Text("M"),
                                  ),
                                  DropdownMenuItem(
                                    value: "F",
                                    child: Text("F"),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                onSaved: (val) => setState(() {
                                  //_service = int.parse(_valueSaved);
                                }),
                                validator: (String? v) {
                                  // return null;

                                  if (v != null) {
                                    gender = v;
                                    // widget.employee?.gender=gender;
                                    return null;
                                  }
                                  return "Sélectionnez le sexe";
                                },
                                decoration: InputDecoration(
                                    labelText: 'Selectionnez le sexe',
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
                                value: widget.employee?.service,
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
                                    serviceName = v;
                                    // widget.employee?.service=serviceName;
                                    return null;
                                  }
                                  return "Sélectionnez le service";
                                },
                                onSaved: (val) => setState(() {
                                  // _service = int.parse(_valueSaved);
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
                                value: widget.employee?.entryTime,
                                items:  const [
                                  DropdownMenuItem(
                                    value: "07:00",
                                    child: Text("07:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "08:00",
                                    child: Text("08:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "09:00",
                                    child: Text("09:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "10:00",
                                    child: Text("10:00"),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                validator: (String? v) {
                                  // return null;

                                  if (v != null) {
                                    entryTime = v;
                                    // widget.employee?.entryTime=entryTime;
                                    return null;
                                  }
                                  return "Sélectionnez l'heure d'arrivée";
                                },
                                onSaved: (val) => setState(() {
                                  // _service = int.parse(_valueSaved);
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
                              DropdownButtonFormField(
                                value: widget.employee?.exitTime,
                                items: const [
                                  DropdownMenuItem(
                                    value: "12:00",
                                    child: Text("12:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "13:00",
                                    child: Text("13:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "14:00",
                                    child: Text("14:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "15:00",
                                    child: Text("15:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "16:00",
                                    child: Text("16:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "17:00",
                                    child: Text("17:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "18:00",
                                    child: Text("18:00"),
                                  ),
                                  DropdownMenuItem(
                                    value: "19:00",
                                    child: Text("19:00"),
                                  ),
                                ],
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                onSaved: (val) => setState(() {
                                  // _service = int.parse(_valueSaved);
                                }),
                                validator: (String? v) {
                                  // return null;

                                  if (v != null) {
                                    exitTime = v;
                                    return null;
                                  }
                                  return "Sélectionnez l'heure de sortie";
                                },
                                decoration: InputDecoration(
                                    labelText: "Selectionnez l'heure de sortie",
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
                                DateActionContainer
                                  (
                                  dateChanging: dateChanging,
                                    title: 'Date de début',
                                    selectedDate:
                                    utils.frenchFormatDate(
                                         widget.employee==null?
                                         start:widget.employee?.startDate),
                                    onSelectDate:
                                        () async {
                                          await  selectDate();

                                          if( widget.employee!=null){
                                           setState(() {
                                             widget.employee?.startDate=start;
                                           });
                                          }

                                        }
                                ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CustomElevatedButton(text: "Annuler",

                                      onPressed: () =>
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  RegisterEmployee()))
                                    ,
                                  ),

                                  CustomElevatedButton(
                                    text: 'Suivant',
                                    onPressed: () async {

                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();

                                        handleRegisterEmployee(context);
                                      }
                                    },
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
