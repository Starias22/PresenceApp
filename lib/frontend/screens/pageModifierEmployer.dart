import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/employe.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:select_form_field/select_form_field.dart';



class FormulaireModifierEmploye extends StatefulWidget {
  Employe employe;
   FormulaireModifierEmploye({Key? key, required this.employe}) : super(key: key);

  @override
  State<FormulaireModifierEmploye> createState() => _FormulaireModifierEmployeState();
}

class _FormulaireModifierEmployeState extends State<FormulaireModifierEmploye> {

  //final key = GlobalKey<DropdownSearchState>();

  late String _nom;
  late String _prenom;
  late String _sexe;
  late String _email;
  late int _service;
  late int _hArrivee;
  late int _hSortie;
  late String _selectedValue;

  final List<String> item = ["Masculin", "Feminin"];

  final List<Map<String, dynamic>> _items = [
    {
      'value' : '0',
      'label' : 'Comptabilité'
    },
    {
      'value' : '1',
      'label' : 'Direction'
    },
    {
      'value' : '2',
      'label' : 'Secrétariat administratif'
    },
    {
      'value' : '3',
      'label' : 'Service de coorpération'
    },
    {
      'value' : '4',
      'label' : 'Service de scolarité'
    }
  ];

  String _valueChanged = '';
  String _valueToValidate = '';
  String _valueSaved = '';
  final _key = GlobalKey<FormState>();

  final GlobalKey<FormState> _oFormKey = GlobalKey<FormState>();
  TextEditingController? _controller;

  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = 'circleValue';
        _controller?.text = 'circleValue';
      });
    });
  }

  @override
  void initState()
  {
    super.initState();

    _controller = TextEditingController(text: '2');

    _getValue();

    /*_service = int.parse(widget.employe.service.toString());
    _sexe = widget.employe.sexe.toString();
    _hArrivee = widget.employe.heureArrivee.toString();
    _hSortie = widget.employe.heureSortie.toString();*/
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> itemsS;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Modifier les informations du compte",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              leading: IconButton(
                  onPressed: () => {Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => const StatistiquesForServices()))},
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
                                  initialValue: widget.employe.nom,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    if (v != null && v.length !=0) {
                                      return null;
                                    }
                                    else {
                                      return "Entrez le nom de l'employé";
                                    }
                                  },
                                  onSaved: (String? v) {
                                    _nom = v!;
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
                                  initialValue: widget.employe.prenom,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    if (v != null && v.length !=0) {
                                      return null;
                                    }
                                    else {
                                      return "Entrez le(s) prenom(s) de l'employé";
                                    }
                                  },
                                  onSaved: (String? v) {
                                    _nom = v!;
                                  },
                                  decoration: InputDecoration(
                                      label: const Text('Prenom(s):'), hintText: "Ex: John",

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
                                  initialValue: widget.employe.email,
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
                                    _email = v!;
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

                              /*DropdownButtonFormField(
                                //value: _valueSaved = _sexe,
                                value: widget.employe.sexe.toString(),
                                items: itemsS = [
                                  const DropdownMenuItem(value: "masculin",child: Text("M"),),
                                  const DropdownMenuItem(value: "feminin",child: Text("F"),),
                                ],
                                onChanged: (val) => setState(() => _valueChanged = val!),
                                validator: (val) {
                                  setState(() => _valueToValidate = val ?? '');
                                  return null;
                                },
                                onSaved: (val) => setState(() {
                                  _valueSaved = val ?? '';
                                  _sexe =  _valueSaved;
                                }),
                                decoration: InputDecoration(
                                    labelText: 'Selectionnez le sexe',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    )
                                ),
                              ),

                              const SizedBox(height: 12,),

                              DropdownButtonFormField(
                                //value: _valueSaved = _service.toString(),
                                value: widget.employe.service.toString(),
                                items: itemsS = [
                                  const DropdownMenuItem(value: "service 1",child: Text("Comptabilité"),),
                                  const DropdownMenuItem(value: "service 2",child: Text("Direction"),),
                                  const DropdownMenuItem(value: "service 3",child: Text("Secrétariat administratif"),),
                                  const DropdownMenuItem(value: "service 4",child: Text("Service de coopération"),),
                                  const DropdownMenuItem(value: "service 5",child: Text("Service de scolarité"),),
                                ],
                                onChanged: (val) => setState(() => _valueChanged = val!),
                                validator: (val) {
                                  setState(() => _valueToValidate = val ?? '');
                                  return null;
                                },
                                onSaved: (val) => setState(() {
                                  _valueSaved = val ?? '';
                                  _service =  int.parse(_valueSaved);
                                }),
                                decoration: InputDecoration(
                                    labelText: 'Selectionnez le service',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    )
                                ),
                              ),

                              const SizedBox(height: 12,),

                              DropdownButtonFormField(
                                //value: _valueSaved = _hArrivee,
                                value: widget.employe.heureArrivee.toString(),
                                items: itemsS = [
                                  const DropdownMenuItem(value: "ha1",child: Text("07"),),
                                  const DropdownMenuItem(value: "ha2",child: Text("08"),),
                                  const DropdownMenuItem(value: "ha3",child: Text("09"),),
                                  const DropdownMenuItem(value: "ha4",child: Text("10"),),
                                ],
                                onChanged: (val) => setState(() => _valueChanged = val!),
                                validator: (val) {
                                  setState(() => _valueToValidate = val ?? '');
                                  return null;
                                },
                                onSaved: (val) => setState(() {
                                  _valueSaved = val ?? '';
                                  _hArrivee =  _valueSaved;
                                }),
                                decoration: InputDecoration(
                                    labelText: "Selectionnez l'heure d'arrivée",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    )
                                ),
                              ),

                              const SizedBox(height: 12,),

                              DropdownButtonFormField(
                                //value: _valueSaved = _hSortie,
                                value: _hSortie = widget.employe.heureSortie.toString(),
                                items: itemsS = [
                                  const DropdownMenuItem(value: "hs1",child: Text("12"),),
                                  const DropdownMenuItem(value: "hs2",child: Text("13"),),
                                  const DropdownMenuItem(value: "hs3",child: Text("14"),),
                                  const DropdownMenuItem(value: "hs4",child: Text("15"),),
                                  const DropdownMenuItem(value: "hs5",child: Text("16"),),
                                  const DropdownMenuItem(value: "hs6",child: Text("17"),),
                                  const DropdownMenuItem(value: "hs7",child: Text("18"),),
                                  const DropdownMenuItem(value: "hs8",child: Text("19"),),
                                ],
                                onChanged: (val) => setState(() => _valueChanged = val!),
                                validator: (val) {
                                  setState(() => _valueToValidate = val ?? '');
                                  return null;
                                },
                                onSaved: (val) => setState(() {
                                  _valueSaved = val ?? '';
                                  _hSortie =  _valueSaved;
                                }),
                                decoration: InputDecoration(
                                    labelText: "Selectionnez l'heure de sortie",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                      borderSide: const BorderSide(color: Colors.red),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: const BorderSide(color: Colors.green),
                                    )
                                ),
                              ),*/

                              DropdownButtonFormField(
                                value: widget.employe.SexeString(),
                                items: const [
                                  DropdownMenuItem(value: "masculin", child: Text("Masculin")),
                                  DropdownMenuItem(value: "fememin", child: Text("Feminin")),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _valueChanged = val ?? '';
                                  });
                                },
                                validator: (val) {
                                  setState(() {
                                    _valueToValidate = val ?? '';
                                  });
                                  return null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    _valueSaved = val ?? '';
                                    _sexe = _valueSaved;
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
                                value: widget.employe.service.index.toString(),
                                items: const [
                                  DropdownMenuItem<String>(value: "0", child: Text("Comptabilité"),),
                                  DropdownMenuItem<String>(value: "1", child: Text("Direction"),),
                                  DropdownMenuItem<String>(value: "2", child: Text("Secrétariat administratif"),),
                                  DropdownMenuItem<String>(value: "3", child: Text("Service de coopération"),),
                                  DropdownMenuItem<String>(value: "4", child: Text("Service de scolarité"),),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _valueChanged = val!;
                                  });
                                },
                                validator: (val) {
                                  setState(() {
                                    _valueToValidate = val ?? '';
                                  });
                                  return null;
                                },
                              onSaved: (val) {
                                setState(() {
                                  _valueSaved = val ?? '';
                                  _service = int.parse(_valueSaved);
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
                            value: widget.employe.heureArrivee.toString(),
                            items: const [
                              DropdownMenuItem<String>(value: "7", child: Text("07"),),
                              DropdownMenuItem<String>(value: "8", child: Text("08"),),
                              DropdownMenuItem<String>(value: "9", child: Text("09"),),
                              DropdownMenuItem<String>(value: "10", child: Text("10"),),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _valueChanged = val!;
                              });
                            },
                            validator: (val) {
                              setState(() {
                                _valueToValidate = val ?? '';
                              });
                              return null;
                            },
                            onSaved: (val) {
                              setState(() {
                                _valueSaved = val ?? '';
                                _hArrivee = int.parse(_valueSaved);
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
                            value: widget.employe.heureSortie.toString(),
                            items: const [
                              DropdownMenuItem<String>(value: "12", child: Text("12"),),
                              DropdownMenuItem<String>(value: "13", child: Text("13"),),
                              DropdownMenuItem<String>(value: "14", child: Text("14"),),
                              DropdownMenuItem<String>(value: "15", child: Text("15"),),
                              DropdownMenuItem<String>(value: "16", child: Text("16"),),
                              DropdownMenuItem<String>(value: "17", child: Text("17"),), 
                              DropdownMenuItem<String>(value: "18", child: Text("18"),), 
                              DropdownMenuItem<String>(value: "19", child: Text("19"),),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _valueChanged = val!;
                              });
                            },
                            validator: (val) {
                              setState(() {
                                _valueToValidate = val ?? '';
                              });
                              return null;
                            },
                            onSaved: (val) {
                              setState(() {
                                _valueSaved = val ?? '';
                                _hSortie = int.parse(_valueSaved);
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
                                  ElevatedButton(
                                    onPressed: ()=>  Navigator.pushReplacement(context, MaterialPageRoute(
                                        builder: (context) => const StatistiquesForServices())),
                                    child: const Text("Annuler"),
                                  ),

                                  //SizedBox(width: MediaQuery.of(context).size.width/3,),

                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();
                                        widget.employe.nom = _nom;
                                        widget.employe.prenom = _prenom;
                                        widget.employe.email = _email;
                                        widget.employe.sexe = _sexe as TypeSexe;
                                        widget.employe.service = _service as TypeService;
                                        widget.employe.heureArrivee = _hArrivee;
                                        widget.employe.heureSortie = _hSortie;

                                        print(widget.employe.nom);
                                        print(_nom);
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
            )
        )
    );
  }
}
