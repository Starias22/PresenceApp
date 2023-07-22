// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/frontend/screens/admins_list.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/custom_snack_bar.dart';

import '../../utils.dart';
import 'adminCompte.dart';


class UpdateAdmin extends StatefulWidget {
   Admin admin;
  final bool himself;
  UpdateAdmin({Key? key, required this.admin, this.himself=true}) : super(key: key);

  @override
  State<UpdateAdmin> createState() => _UpdateAdminState();
}

class _UpdateAdminState extends State<UpdateAdmin> {
  void updateAdminData(Admin newAdmin) {
    setState(() {
      widget.admin = newAdmin;
    });
  }

  late String _nom;
  late String _prenom;
  late String _email;
  bool updateInProgress=false;
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
              centerTitle: true,
              backgroundColor: appBarColor,
              title: const Text("Modifier les informations",
                style: TextStyle(
                  fontSize: appBarTextFontSize,
                ),
              ),

              leading: IconButton(
                  onPressed: () => {

                    if(widget.himself)
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => const AdminAccount()))

                    else
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => const AdminsList()))

                  }


                  ,

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
                                enabled: widget.himself,
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
                                  CustomElevatedButton(
                                      text:  "Annuler",
                                      onPressed: () => {

                                        if(widget.himself)
                                          Navigator.pushReplacement(context, MaterialPageRoute(
                                              builder: (context) => const AdminAccount()))

                                        else
                                          Navigator.pushReplacement(context, MaterialPageRoute(
                                              builder: (context) => const AdminsList()))

                                      }


                                  ),


                                  //SizedBox(width: MediaQuery.of(context).size.width/3,),

                                updateInProgress?
                                const CircularProgressIndicator():  CustomElevatedButton(
                                    onPressed: ()  async {
                                      if (_key.currentState!.validate()) {
                                        _key.currentState!.save();

                                       }
                                      setState(() {
                                        updateInProgress=true;
                                      });
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

                                      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                                        simple: true,
                                        showCloseIcon: false,
                                        duration: const Duration(seconds: 5) ,
                                        //width: MediaQuery.of(context).size.width-2*10,
                                        message:message ,
                                      ));

                                      if(_email!=widget.admin.email){

                                        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                                          simple: true,
                                          showCloseIcon: false,
                                          duration: const Duration(seconds: 5) ,
                                          //width: MediaQuery.of(context).size.width-2*10,
                                          message: "Un email de modification d'adresse email a été envoyé à votre adresse email ${widget.admin.email}" ,
                                        ));

                                      }
                                      setState(() {
                                        updateInProgress=false;
                                      });

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
