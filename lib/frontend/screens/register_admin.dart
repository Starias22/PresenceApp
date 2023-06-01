import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/models/admin.dart';

import 'package:presence_app/frontend/screens/pageStatistiques.dart';

class RegisterAdmin extends StatefulWidget {
  const RegisterAdmin({Key? key}) : super(key: key);
  void cancel() {}

  @override
  State<RegisterAdmin> createState() => _RegisterAdminState();
}

class _RegisterAdminState extends State<RegisterAdmin> {
  late String passwd;
  TextEditingController fnameC = TextEditingController();
  TextEditingController lnameC = TextEditingController(),
      emailC = TextEditingController(),
      passwordC = TextEditingController(),
      confirmC = TextEditingController();
  late String fname, lname, email, password, confirm;
  final _key = GlobalKey<FormState>();
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  void retrieveTexts() {
    fname = fnameC.text;
    lname = lnameC.text;
    email = emailC.text;
    password = passwordC.text;
    confirm = confirmC.text;
  }

  void reset() {
    fnameC.text = '';
    lnameC.text = '';
    emailC.text = '';
    passwordC.text = '';
    confirmC.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Creation compte admin",
          style: TextStyle(
            fontSize: 20,
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
      body: ListView(scrollDirection: Axis.vertical, children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  TextFormField(
                      controller: lnameC,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (String? v) {
                        if (v != null && v.isNotEmpty) {
                          return null;
                        } else {
                          return "Entrez le nom de l'employé";
                        }
                      },
                      onSaved: (String? v) {},
                      decoration: InputDecoration(
                          label: const Text('Nom:'),
                          hintText: "Ex: ADEDE",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ))),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                      controller: fnameC,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (String? v) {
                        if (v != null && v.isNotEmpty) {
                          return null;
                        } else {
                          return "Entrez le(s) prenom(s) de l'employé";
                        }
                      },
                      onSaved: (String? v) {},
                      decoration: InputDecoration(
                          label: const Text('Prénom(s):'),
                          hintText: "Ex: John",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ))),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                      controller: emailC,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (String? v) {
                        if (v != null && EmailValidator.validate(v)) {
                          return null;
                        } else {
                          return "Email invalide";
                        }
                      },
                      onSaved: (String? v) {},
                      decoration: InputDecoration(
                          label: const Text('Email:'),
                          hintText: "Ex: employe@gmail.com",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ))),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                      controller: passwordC,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      validator: (String? v) {
                        if (v!.isNotEmpty && v.length >= 6) {
                          passwd = v;
                          return null;
                        } else {
                          return "Entrez un mot de passe";
                        }
                      },
                      onSaved: (String? v) {},
                      decoration: InputDecoration(
                          label: const Text('Password:'),
                          hintText: "Ex: ...........",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ))),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                      controller: confirmC,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      validator: (String? v) {
                        if (v!.isNotEmpty && v == passwd) {
                          return null;
                        }
                        if (v != passwd) {
                          return 'Confirmation incorrecte';
                        } /*else {
                          return "Confirmez le mot de passe";
                        }*/
                      },
                      onSaved: (String? v) {},
                      decoration: InputDecoration(
                          label: const Text(
                              'Confirmez le mot de passe'), //hintText: "Ex: John",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          ))),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => {reset()},
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          
                          if (_key.currentState!.validate()) {
                            _key.currentState!.save();
                          } else {
                            return;
                          }

                          retrieveTexts();
                          Admin admin = Admin(
                              firstname: fname,
                              lastname: lname,
                              email: email,
                              password: password);


                          String message;


        if(await AdminDB().create(admin)){

          if(await Login().signUp(email, password)){
            message = 'Admin enregistré avec succès';
            reset();
          }
          else{
            String? id=await AdminDB().getAdminIdByEmail(email);
            AdminDB().delete(id!);
            message="Une erreur s'est produite! Veillez reessayer!";
          }

        }
        else{
          message = 'Email déjà attribué';
        }

                  

                          showToast(message);
                          
                        },
                        child: const Text('Confirmer'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
