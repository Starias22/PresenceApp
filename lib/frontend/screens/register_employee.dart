import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class RegisterEmployee extends StatefulWidget {
  const RegisterEmployee({Key? key}) : super(key: key);

  @override
  State<RegisterEmployee> createState() => _RegisterEmployeeState();
}

class _RegisterEmployeeState extends State<RegisterEmployee> {
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  DateTime? selectedDate;
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
                //return;

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

    if(!fingerprintSaved){
      ToastUtils.showToast(context, "Empreinte non enregistrée!", 3);
      return;
    }





    Employee employee=Employee


      ( firstname: firstname,
        gender: gender, lastname: lastname,
        email: email, service:serviceName,
        startDate: start, entryTime: entryTime,
        exitTime: exitTime);

    String message;
    bool created=false;





    if(await EmployeeDB().create(employee)){
      message='Employé enregistré avec succès';
      created=true;
    }
    else{
      message=  'Cette adresse email a été déjà attribuée à un employé';
    }
    ToastUtils.showToast(context, message, 3);

    if(created) {
    }



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
  void saveFingerprint() {

    print('Fingerprint saved!');
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
                Padding(
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
                    child: IconButton(
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
                                    saveFingerprint();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        //showServiceDialog(context);
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
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
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
                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _valueChanged = val!),
                                validator: (String? v) {
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
                                      } else {
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
