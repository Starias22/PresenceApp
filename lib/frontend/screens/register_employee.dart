// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/esp32.dart';
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
  bool canEnrollFingerprint=false;
  late DateTime today;
  DateTime start=DateTime.now();
  bool dataChanging=false;
   String startDate='JJ/MM/AAAA';
   bool fingerprintEnrolled = false;
   late int fingerprintId;
   Employee? employee;




  void disableFingerprintEnrollmentIfPreviouslyEnabled(){

    if(canEnrollFingerprint) {
      setState(() {
      canEnrollFingerprint=false;

    });
    }

  }

  Future<int> assureDataChanged(int fingerprintId,int val ) async {
    int data = fingerprintId ;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();

      if (cpt == 10) {

        return 152;
      }


      if (data ==val) {
        log.d('Data changed');
        return data;
      }
      else {
        cpt++;
        await Future.delayed(const Duration(seconds: 1));
        return await fetchData();
      }

    }

    return await fetchData();
  }


  Future<int> getData(int val) async {
    int data = val;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();
      if (cpt == 10 ||( data != val && data!=-1)) {
        log.d('Condition satisfied');
        return data;
      } else {
        cpt++;
        await Future.delayed(const Duration(seconds: 1));
        return await fetchData();
      }
    }

    return await fetchData();
  }

  Future<int> g() async {
    int data = 150;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();
      if (cpt == 10 ||(  data!=-1&&data!=150)) {
        log.d('Condition satisfied');
        return data;
      } else {
        cpt++;
        await Future.delayed(const Duration(seconds: 1));
        return await fetchData();
      }
    }

    return await fetchData();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }


  Future<void> enrolFingerprint() async {


    String networkConnectionError;
    String espConnectionError = "Vérifiez la configuration du microcontrôleur et ressayez";
    if ( await Connectivity().checkConnectivity() == ConnectivityResult.none) {


       networkConnectionError = "Vérifiez votre connexion internet et reessayez";

      ToastUtils.showToast(context, networkConnectionError,3);
      return;
    }

    if (!(await ESP32().sendData('enroll'))){
      ToastUtils.showToast(context, espConnectionError, 3);
      return;
    }

    ToastUtils.showToast(context, ""
        "Placez votre doigt sur le capteur pour démarrer", 3);


    int  data=await getData(150);

    log.d(data);

    if(data==150) {


      ToastUtils.showToast(context, "Aucun doigt détecté", 3);
      return;
    }
    if(data==espConnectionFailed) {


      ToastUtils.showToast(context, espConnectionError, 3);
      return;
    }
    ToastUtils.showToast(context, "Vérification de l'existence de votre empreinte en cours!", 3);


    if(minFingerprintId<=data&&data<=maxFingerprintId)//alredy exists
        {
      ToastUtils.showToast(context, "Une empreinte correspondante a été "
          "déjà enregistrée au sein du capteur", 3);
      return;

    }


    if(data==noMatchingFingerprint)//save 151
        {
      ToastUtils.showToast(context, "Retirez votre doigt du capteur", 3);
      await ESP32().sendData('go');

      // ToastUtils.showToast(context, "Empreinte en cours d'enregistrement! "
      //     "Maintenez votre doigt sur le capteur", 3);
      ToastUtils.showToast(context, "L'enregistrement peut démarrer à présent! "
          "Placez à nouveau!", 3);


 //merveil bandit
      data = await getData(151);

      if (data == 151) {
        ToastUtils.showToast(context,
            "Aucun doigt détecté! Echec de l'enregistrement", 3);
        return;
      }

      log.d('Data1:hhh $data ');
      if (data == -15) {
        ToastUtils.showToast(context, ""
            "Retirez votre doigt du capteur, pour passer à la vérification"
            "de la correspondance", 3);

        data = await getData(-15);
        log.d('Data1222:hhh $data ');

        if (minFingerprintId <= data && data <= maxFingerprintId) //saved
            {


          log.d('merveil bandit:');
          ToastUtils.showToast(context, ""
              "Placez à nouveau votre doigt pour la vérification de correspondance", 3);


          int x = await getData(data);

          log.d('ezechiel bandit: $x');

          if (x == noMatchingFingerprint) {
            ToastUtils.showToast(context,
                "Empreintes non correspondantes! Echec de l'enregistrement", 3);

          }

          if (x == espConnectionFailed) {
            ToastUtils.showToast(
                context, "$espConnectionError! Echec de l'enregistrement", 3);
          }


          if (x == 255) {
            log.d('The data is:$x');
              fingerprintId = data;
              setState(() {
                fingerprintEnrolled = true;
              });
            ToastUtils.showToast(context,
                "Enregistrement terminé! Vous pouvez retirer votre doigt du capteur",
                3);
            //create the employee

            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    RegisterEmployee()));
            await assureDataChanged(x, 2000);
            ESP32().sendData('-1');


            return;
          }

          if(x==data){
            ToastUtils.showToast(context,
                "Aucun doigt détecté! Echec de l'enregistrement", 3);

          }


        }

        else if (data == -15) {
          ToastUtils.showToast(context, "Aucun doigt détecté", 3);
          return;
        }


        if (data == espConnectionFailed) {
          ToastUtils.showToast(context, espConnectionError, 3);
          return;
        }
      }
    }

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
      DateTime nextWorkDate=utils.getNextWorkDate(today);


      selectedDate = await  showDatePicker(context: context,

        locale: const Locale('fr'),
        initialDate:nextWorkDate ,
        firstDate: utils.isWeekend(today)?nextWorkDate:today ,
        lastDate:lastDate,
        currentDate: today,
      );

      setState(() {
        dataChanging=true;
      });

      if(selectedDate==null){
        ToastUtils.showToast(context, "Date de début de travail non sélectionnée", 3);
        setState(() {
          dataChanging=false;
        });
        return;
      }
       start=selectedDate!;

      if(utils.isWeekend(start)){
        disableFingerprintEnrollmentIfPreviouslyEnabled();
        ToastUtils.showToast(context, "La date de début de travail ne doit pas être un weekend", 3);
        setState(() {
          dataChanging=false;
        });
        return;
      }


      if((await HolidayDB().isHoliday(start))){
      disableFingerprintEnrollmentIfPreviouslyEnabled();
      ToastUtils.showToast(context, "Cette date de début est définie comme un jour férié ou de congés", 3);

      setState(() {
        dataChanging=false;
      });
      return;
      }

      log.d('before The start date is :$startDate');
      setState(() {
      startDate=utils.frenchFormatDate(start);
      });
      log.d('after The start date is :$startDate');
      setState(() {
        dataChanging=false;
      });


    }
    //#######################################################################
  Future<void> handleRegisterEmployee(BuildContext context) async {


    // Employee employee=Employee
    //   ( firstname: firstname,
    //     gender: gender, lastname: lastname,
    //     email: email, service:serviceName,
    //     startDate: start, entryTime: entryTime,
    //     exitTime: exitTime);

    Employee employee=Employee
      ( firstname: 'John',
        gender: 'M', lastname: 'LOLA',
        email: 'email', service:'Direction',
        startDate: DateTime.now(), entryTime: '08:00',
        exitTime: '17:00');


    String message;


    if(await EmployeeDB().exists(employee.email)){
      disableFingerprintEnrollmentIfPreviouslyEnabled();
      message=  'Cette adresse email a été déjà attribuée à un employé';
      ToastUtils.showToast(context, message, 3);
      return;

    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
             EnrollFingerprint(
               employee:employee,)));


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
    DateTime now=await utils.localTime();
    today=DateTime(now.year,now.month,now.day);



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
    setState(() {
      startDate=utils.frenchFormatDate(start);
    });

    _getValue();
  }

  @override
  Widget build(BuildContext context) {
    employee = widget.employee;

    retrieveServices();

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
              actions: [
             if(canEnrollFingerprint)   Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueGrey,
                    ),
                    child:  IconButton(
                      tooltip: "Enregistrer l'empreinte",
                      onPressed: () async {

                       await  showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomAlertDialog(
                              title: "Enregistrer l'empreinte",
                              message: "Continuer pour enregistrer l'empreinte de l'employé",
                              positiveOption: 'Continuer',
                              context: context,
                            );
                          },
                        );
                       enrolFingerprint();
                      },
                      icon: const Icon(Icons.fingerprint, color: Colors.black, ),
                    ),
                  ),
                )
              ],
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
                              TextFormField(
                                  initialValue: employee?.lastname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,

                                  validator: (String? v) {

                                    if (v != null && v.isNotEmpty) {
                                      lastname = v;
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
                                  initialValue: employee?.firstname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    // return null;

                                    if (v != null && v.isNotEmpty) {
                                      firstname = v;
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
                                  initialValue: employee?.email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    // return null;

                                    if (v != null &&
                                        EmailValidator.validate(v)) {
                                      email = v;
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
                                value: employee?.gender,
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
                                value: employee?.service,
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
                                value: employee?.entryTime,
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
                                value: employee?.exitTime,
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
                                  dateChanging: dataChanging,
                                    title: 'Date de début',
                                    selectedDate:
                                    employee==null?startDate

                                        : utils.frenchFormatDate(employee?.startDate),
                                    onSelectDate:
                                        () async {
                                          await  selectDate();
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
                                      //
                                      // if (_key.currentState!.validate()) {
                                      //   _key.currentState!.save();
                                      //
                                      //   handleRegisterEmployee(context);
                                      // }

                                      handleRegisterEmployee(context);



                                    },),
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
