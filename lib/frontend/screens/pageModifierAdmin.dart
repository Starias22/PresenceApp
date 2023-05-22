import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/admin.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';


class FormulaireModifierAdmin extends StatefulWidget {
  Admin admin;
  FormulaireModifierAdmin({Key? key, required this.admin}) : super(key: key);

  @override
  State<FormulaireModifierAdmin> createState() => _FormulaireModifierAdminState();
}

class _FormulaireModifierAdminState extends State<FormulaireModifierAdmin> {

  //final key = GlobalKey<DropdownSearchState>();

  late String _nom;
  late String _prenom;
  late String _sexe;
  late String _email;

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

  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> itemsS;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Modifier les informations du compte",
                style: TextStyle(
                  //fontSize: 15,
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
                                  initialValue: widget.admin.getLname(),
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
                                  initialValue: widget.admin.getFname(),
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
                                  initialValue: widget.admin.getEmail(),
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
                                        widget.admin.setLname(_nom);
                                        widget.admin.setFname(_prenom);
                                        widget.admin.setEmail( _email);
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
