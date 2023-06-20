// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class RegisterEmployee extends StatefulWidget {
  const RegisterEmployee({Key? key}) : super(key: key);

  @override
  State<RegisterEmployee> createState() => _RegisterEmployeeState();
}

class _RegisterEmployeeState extends State<RegisterEmployee> {
  String startDate='JJ/MM/AAAA';


  void disableFingerprintEnrollmentIfPreviouslyEnabled(){

    if(canEnrollFingerprint) {
      setState(() {
      canEnrollFingerprint=false;

    });
    }

  }
  Future<int> assureDataChanged(int fingerprintId ) async {
    int data = fingerprintId ;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();

      if (cpt == 10) {

        return 152;
      }


      if (data ==-1) {
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
    int data = -1;
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
  DateTime? selectedDate;
  bool canEnrollFingerprint=false;
  late DateTime today;

  Future<void> enrolFingerprint() async {
    //String connectionError= 'Erreur de connexion!Veillez reessayer!';
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


    if(minFingerprintId<=data&&data<=maxFingerprintId)//alredy exists
        {
      ToastUtils.showToast(context, "Une empreinte correspondante a été "
          "déjà enregistrée au sein du capteur", 3);
      return;

    }


    if(data==noMatchingFingerprint)//save
        {

      await ESP32().sendData('go');

      ToastUtils.showToast(context, "Empreinte en cours d'enregistrement! "
          "Maintenez votre doigt sur le capteur", 3);


      data=await getData(151);



      log.d('Data:hhh $data ');

      if(1<=data&&data<=127)//saved
          {
        ToastUtils.showToast(context, "Empreinte enregistrée!"
            " Enlevez votre doigt du capteur", 3);

        if(await ESP32().sendData('update')){

          
          int y=await assureDataChanged(data);

          log.d('merveil bandit: $y');

          if(y==152){
            ToastUtils.showToast(context, "Vous n'avez pas enlevé votre doigt! Essayez à nouveau!", 3);
            return;

          }
          if(y==-1){
            ToastUtils.showToast(context, "Placez votre doigt à nouveau pour vérification!", 3);


          }

          //value updated start verification

          if(await ESP32().sendData('enroll')){



            int x=await g();

            log.d('Nouvel id lu: $x');

            if(x==data){
              ToastUtils.showToast(context, "Empreinte vérifiée", 3);
              //create the employee

              return;

            }

            if(x== noFingerDetected){
              ToastUtils.showToast(context, "Aucun doigt détecté", 3);
              return;

            }
            //send the previous saved fingerprint id for delete

            ESP32().sendData(data.toString());
            ToastUtils.showToast(context, "Echec de l'enregistrement! Empreintes non correspndantes", 3);


             if(x==espConnectionFailed){
              ToastUtils.showToast(context, espConnectionError, 3);
            }



          }

        }




          }

      else if(data== noFingerDetected){
        ToastUtils.showToast(context, "Aucun doigt détecté", 3);
        return;

      }


       if(data==espConnectionFailed){
        ToastUtils.showToast(context, espConnectionError, 3);
        return;
      }


    }

    

    }
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
      disableFingerprintEnrollmentIfPreviouslyEnabled();
      ToastUtils.showToast(context, "La date de début de travail ne doit pas être un weekend", 3);
      return;
    }


    if((await HolidayDB().isHoliday(start))){
      disableFingerprintEnrollmentIfPreviouslyEnabled();
      ToastUtils.showToast(context, "Cettte date de début est définie comme un jour férié ou de congés", 3);
      return;
    }
    setState(() {
      startDate=utils.frenchFormatDate(selectedDate);
    });

    //
    //
    // Employee employee=Employee
    //
    //
    //   ( firstname: firstname,
    //     gender: gender, lastname: lastname,
    //     email: email, service:serviceName,
    //     startDate: start, entryTime: entryTime,
    //     exitTime: exitTime);
    //
    // String message;
    //
    //
    //
    // if(await EmployeeDB().exists(employee.email)){
    //   disableFingerprintEnrollmentIfPreviouslyEnabled();
    //   message=  'Cette adresse email a été déjà attribuée à un employé';
    //   ToastUtils.showToast(context, message, 3);
    //   return;
    //
    // }
    //

    setState(() {
      canEnrollFingerprint=true;

    });



    /*if(!fingerprintSaved){
      ToastUtils.showToast(context, "Empreinte non enregistrée!", 3);
      return;
    }

    await EmployeeDB().create(employee);
      message='Employé enregistré avec succès';


    ToastUtils.showToast(context, message, 3);*/





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
                "PresenceApp",
                style: GoogleFonts.arizonia(
                  fontSize: 25,
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
                            return AlertDialog(
                              title: const Text("Enregisterer l'empreinte"),
                              content: const Text("Continuer pour enregistrer l'empreinte de l'employé"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Continuer'),
                                  onPressed: () {

                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
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
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,

                                  validator: (String? v) {
                                    return null;

                                    // if (v != null && v.isNotEmpty) {
                                    //   lastname = v;
                                    //   return null;
                                    // } else {
                                    //   return "Entrez le nom de l'employé";
                                    // }
                                  },
                                  onSaved: (String? v) {
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Nom:'),
                                      hintText: "Ex: ADEDE",
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
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    return null;

                                    // if (v != null && v.isNotEmpty) {
                                    //   firstname = v;
                                    //   return null;
                                    // }
                                    // return "Entrez le(s) prenom(s) de l'employé";
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
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    return null;

                                    // if (v != null &&
                                    //     EmailValidator.validate(v)) {
                                    //   email = v;
                                    //   return null;
                                    // }
                                    // return "Email invalide";
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
                                  return null;

                                  // if (v != null) {
                                  //   gender = v;
                                  //   return null;
                                  // }
                                  // return "Sélectionnez le sexe";
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
                                  return null;

                                  // if (v != null) {
                                  //   entryTime = v;
                                  //   return null;
                                  // }
                                  // return "Sélectionnez l'heure d'arrivée";
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
                                  return null;

                                  // if (v != null) {
                                  //   exitTime = v;
                                  //   return null;
                                  // }
                                  // return "Sélectionnez l'heure de sortie";
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date de début de travail',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10), // Espacement entre le titre et le champ de texte
                                  Container(
                                    width: 125, // Largeur du champ de texte encadré
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      startDate,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

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
                                                const RegisterEmployee())),
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

                                       disableFingerprintEnrollmentIfPreviouslyEnabled();
                                        return;
                                      }
                                      DateTime now=await utils.localTime();
                                      today=DateTime(now.year,now.month,now.day);

                                      selectStartDateAndAchieve(context);



                                    },
                                    child: const Text('Confirmer'),
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
