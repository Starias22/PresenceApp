import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/models/admin.dart';

import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import '../../utils.dart';
import 'adminCompte.dart';


class FormulaireModifierAdmin extends StatefulWidget {
  Admin admin;
  bool updateEmail;
  FormulaireModifierAdmin({Key? key, required this.admin, this.updateEmail=false}) : super(key: key);

  @override
  State<FormulaireModifierAdmin> createState() => _FormulaireModifierAdminState();
}

class _FormulaireModifierAdminState extends State<FormulaireModifierAdmin> {
  void updateAdminData(Admin newAdmin) {
    setState(() {
      widget.admin = newAdmin;
    });
  }

  //final key = GlobalKey<DropdownSearchState>();

  late String _nom;
  late String _prenom;
  late String _email;

  final _key = GlobalKey<FormState>();

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
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Modifier les informations du compte",
                style: TextStyle(
                  //fontSize: 15,
                ),
              ),

              leading: IconButton(
                  onPressed: () => {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => const AdminCompte()))
                  },

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
                                  initialValue: widget.admin.lastname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    if (v != null && v.isNotEmpty) {
                                      return null;
                                    }
                                      return "Entrez le nom de l'admin";

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
                                  initialValue: widget.admin.firstname,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? v) {
                                    if (v != null && v.isNotEmpty) {
                                      return null;
                                    }

                                      return "Entrez le(s) prenom(s) de l'employé";

                                  },
                                  onSaved: (String? v) {
                                    _prenom = v!;
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
                                enabled: widget.updateEmail,
                                  initialValue: widget.admin.email,
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
                                    onPressed: ()  async {
                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();



                                       /* widget.admin.lastname= _nom;
                                        widget.admin.firstname=_prenom;
                                        widget.admin.email=_email;*/
                                       }
                                      String message;
                                      Admin admin=Admin(firstname: _prenom, lastname:_nom, email: _email,isSuper:widget.admin.isSuper );

                                      if(_prenom==widget.admin.firstname&&
                                          _nom==widget.admin.lastname&&
                                          _email==widget.admin.email
                                      ){
                                        message="Rien n'a changé";
                                      }
                                     else if(widget.admin.email!=_email&&
                                          await AdminDB().exists(admin.email))
                                        {
                                          log.d(widget.admin.email);
                                          log.d(_email);

                                          message="Email déjà attribué à un admin";
                                        }
                                     else{

                                       admin.id=(await AdminDB().getAdminIdByEmail(widget.admin.email))!;
                                       AdminDB().update(admin);
                                       message='Admin modifié avec succès';
                                      }


                                     log.d(message);

                                     updateAdminData(admin);
                                      ToastUtils.showToast(context, message, 3);
                                      if(_email!=widget.admin.email){
                                        Login().updateEmailForCurrentUser(_email);

                                        ToastUtils.showToast(context, "Un email de modification d'adresse email a été envoyé à votre adresse $widget.admin.email", 3);
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
