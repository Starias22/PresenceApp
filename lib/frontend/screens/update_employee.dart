import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/employees_list.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/custom_snack_bar.dart';
import 'package:presence_app/utils.dart';


class UpdateEmployee extends StatefulWidget {
  Employee employee;
   UpdateEmployee({Key? key, required this.employee}) : super(key: key);

  @override
  State<UpdateEmployee> createState() => _UpdateEmployeeState();
}

class _UpdateEmployeeState extends State<UpdateEmployee> {
  Future<void> retrieveServices() async {
    items = await ServiceDB().getServicesNames();
  }
  late String firstname,lastname,gender,email,service,startTime,endTime;
  bool updateInProgress=false;

  late List<String> items = [];



  final List<String> item = ["Masculin", "Feminin"];


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
  void didChangeDependencies() {
    super.didChangeDependencies();
    retrieveServices();
  }

  @override
  Widget build(BuildContext context) {
    retrieveServices();
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appBarColor,
              centerTitle: true,
              title: const Text("Modifier les informations",
                style: TextStyle(
                  fontSize: appBarTextFontSize,
                ),
              ),

              leading: IconButton(
                  onPressed: () => {Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => const EmployeesList()
                  ))},
                  icon: const Icon(Icons.arrow_back,)
              ),
            ),

            body: ListView(
              scrollDirection: Axis.vertical,
              children: [
                const SizedBox(height: 25,),
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
                                  initialValue: widget.employee.lastname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    if (v != null && v.isNotEmpty) {
                                      return null;
                                    }
                                    else {
                                      return "Entrez le nom de l'employé";
                                    }
                                  },
                                  onSaved: (String? v) {
                                    lastname=v!;
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Nom:'), hintText: "Ex: ADEDE",

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0.0),
                                        borderSide: const BorderSide(color: Colors.red),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(color: Colors.green),
                                      )
                                  )
                              ),

                              const SizedBox(height: 12,),

                              TextFormField(
                                  initialValue: widget.employee.firstname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    if (v != null && v.isNotEmpty) {
                                      return null;
                                    }
                                    else {
                                      return "Entrez le(s) prenom(s) de l'employé";
                                    }
                                  },
                                  onSaved: (String? v) {
                                    firstname=v!;
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Prénom(s):'), hintText: "Ex: John",

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0.0),
                                        borderSide: const BorderSide(color: Colors.red),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(color: Colors.green),
                                      )
                                  )
                              ),

                              const SizedBox(height: 12,),

                              TextFormField(
                                enabled: false,
                                  initialValue: widget.employee.email,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,

                                  validator: (String? v) {
                                    if( v != null && EmailValidator.validate(v) )
                                    {
                                      return null;
                                    }
                                    else
                                    {
                                      return "Email invalide";
                                    }
                                  },
                                  onSaved: (String? v) {
                                    email=v!;
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Email:'), hintText: "Ex: employe@gmail.com",

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0.0),
                                        borderSide: const BorderSide(color: Colors.red),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(color: Colors.green),
                                      )
                                  )
                              ),

                              const SizedBox(height: 12,),

                              DropdownButtonFormField(
                                value: widget.employee.gender,
                                items: const [
                                  DropdownMenuItem(value: "M", child: Text("M")),
                                  DropdownMenuItem(value: "F", child: Text("F")),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                  });
                                },
                                validator: (val) {

                                  setState(() {
                                  });
                                  return null;
                                },
                                onSaved: (val) {
                                  gender=val!;
                                  setState(() {
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Selectionnez le sexe',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                    borderSide: const BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: const BorderSide(color: Colors.green),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12,),

                              DropdownButtonFormField<String>(
                                value:widget.employee.service,

                                items: items.map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                  });
                                },
                                validator: (val) {
                                  setState(() {
                                  });
                                  return null;
                                },
                              onSaved: (val) {
                                  service=val!;
                                setState(() {
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Selectionnez le service',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(color: Colors.green),
                                ),
                              ),
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: widget.employee.entryTime,
                            items: const [
                              DropdownMenuItem<String>(value: "07:00", child: Text("07:00"),),
                              DropdownMenuItem<String>(value: "08:00", child: Text("08:00"),),
                              DropdownMenuItem<String>(value: "09:00", child: Text("09:00"),),
                              DropdownMenuItem<String>(value: "10:00", child: Text("10:00"),),
                            ],
                            onChanged: (val) {
                              setState(() {
                              });
                            },
                            validator: (val) {
                              setState(() {
                              });
                              return null;
                            },
                            onSaved: (val) {
                              startTime=val!;
                              setState(() {
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Selectionnez l'heure d'arrivée",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(color: Colors.green),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: widget.employee.exitTime,
                            items: const [
                              DropdownMenuItem<String>(value: "12:00", child: Text("12:00"),),
                              DropdownMenuItem<String>(value: "13:00", child: Text("13:00"),),
                              DropdownMenuItem<String>(value: "14:00", child: Text("14:00"),),
                              DropdownMenuItem<String>(value: "15:00", child: Text("15:00"),),

                              DropdownMenuItem<String>(value: "16:00", child: Text("16:00"),),
                              DropdownMenuItem<String>(value: "17:00", child: Text("17:00"),),
                              DropdownMenuItem<String>(value: "18:00", child: Text("18:00"),),
                              DropdownMenuItem<String>(value: "19:00", child: Text("19:00"),),
                            ],
                            onChanged: (val) {
                              setState(() {
                              });
                            },
                            validator: (val) {
                              setState(() {
                              });
                              return null;
                            },
                            onSaved: (val) {
                              endTime=val!;
                              setState(() {
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Selectionnez l'heure de sortie",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.0),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: const BorderSide(color: Colors.green),
                              ),
                            ),
                          ),

                              const SizedBox(height: 12,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CustomElevatedButton(
                                    onPressed: ()=>  Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (context) => const EmployeesList())),
                                    text: "Annuler",
                                  ),

                                  //SizedBox(width: MediaQuery.of(context).size.width/3,),

                                 updateInProgress?
                                 const CircularProgressIndicator(): CustomElevatedButton(

                                    onPressed: () async {
                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();
                                        setState(() {
                                          updateInProgress=true;
                                        });
                                        String? id=await EmployeeDB().getEmployeeIdByEmail(widget.employee.email);
                                      log.d('id of the employee:$id');
                                       Employee employee=
                                       Employee(
                                         pictureDownloadUrl: widget.employee.pictureDownloadUrl,
                                           status: widget.employee.status,
                                           service:
                                       service, id: id!, firstname:
                                       firstname,
                                           gender:
                                       gender, lastname: lastname, email:
                                       email, startDate: widget.employee.startDate,
                                           entryTime:
                                       startTime, exitTime: endTime,
                                           fingerprintId: widget.employee.fingerprintId,
                                       //uniqueCode: widget.employee.uniqueCode
                                       );
                                      log.i('we are gona update');

                                       await EmployeeDB().update(employee);
                                        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                                          simple: true,
                                          showCloseIcon: false,
                                          duration: const Duration(seconds: 5) ,
                                          //width: MediaQuery.of(context).size.width-2*10,
                                          message:'Employé modifié avec succès' ,
                                        ));
                                        setState(() {
                                            updateInProgress=false;
                                        });

                                      }
                                    },
                                   text: 'Confirmer',
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
            )
        )
    );
  }
}
