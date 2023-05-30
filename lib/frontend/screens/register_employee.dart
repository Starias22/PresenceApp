import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/new_back/firestore/employee_db.dart';
import 'package:presence_app/backend/new_back/firestore/holiday_db.dart';
import 'package:presence_app/backend/new_back/firestore/service_db.dart';
import 'package:presence_app/backend/new_back/models/employee.dart';

import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/widgets/toast.dart';

import '../../utils.dart';

class RegisterEmployee extends StatefulWidget {
  const RegisterEmployee({Key? key}) : super(key: key);

  @override
  State<RegisterEmployee> createState() => _RegisterEmployeeState();
}

class _RegisterEmployeeState extends State<RegisterEmployee> {

  late String firstname, lastname, email, serviceName, gender, entryTime, exitTime;

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
              centerTitle: true,
              title: const Text(
                "Création de compte employé",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              leading: IconButton(
                  onPressed: () => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StatistiquesForServices()))
                      },
                  icon: const Icon(
                    Icons.arrow_back,
                  )),
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
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterEmployee())),
                                    /* Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StatistiquesForServices())),*/
                                    child: const Text("Annuler"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();
                                      } else {
                                        return;
                                      }

                                      DateTime now=DateTime.now();
                                      DateTime today=DateTime(now.year,now.month,now.day);
                                      DateTime start=DateTime(now.year,now.month,now.day+1);


                                      Employee employee=Employee


                                        ( firstname: firstname,
                                          gender: gender, lastname: lastname,
                                          email: email, service:serviceName,
                                          startDate: start, entryTime: entryTime, exitTime: exitTime);

                                      String message;
                                      bool created=false;
                                      if(start.isBefore(today)){
                                        message="La date de début doit être au moins aujourd'hui";
                                      }
                                      else if(utils.isWeekend(start)){
                                        message="Cette date de début est un weekend";
                                      }

                                      else if((await HolidayDB().isHoliday(start))){
                                        message="Cettte date de début est définie comme un jour férié ou de congés";
                                      }


                                      else if(await EmployeeDB().create(employee)){
                                        message='Employé enregistré avec succès';
                                        created=true;
                                      }
                                      else{
                                      message=  'Cette adresse email a été déjà attribuée à un employé';
                                      }
                                     ToastUtils.showToast(context, message, 3);

                                       if(created) {
                                         Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const RegisterEmployee()));
                                       }
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
