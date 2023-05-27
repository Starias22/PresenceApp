import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/new_back/firestore/admin_db.dart';
import 'package:presence_app/bridge/login.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';
import 'package:presence_app/frontend/widgets/toast.dart';

import 'package:presence_app/utils.dart';

import '../../backend/services/login.dart';

class Authentification extends StatefulWidget {
  const Authentification({Key? key}) : super(key: key);

  @override
  State<Authentification> createState() => _AuthentificationState();
}

class _AuthentificationState extends State<Authentification> {
  bool loginInProcess = false;
  final _key = GlobalKey<FormState>();
  bool _isSecret = true;

  TextEditingController emailC = TextEditingController(),
      passwordC = TextEditingController();

  String? email, password;

  void showToast(String message) {
    ToastUtils.showToast(context, message, 3);
  }

  void retrieveTexts() {
    email = emailC.text;
    password = passwordC.text;
  }

  void reset() {
    emailC.text = '';
    passwordC.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Authentification",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Card(
                    color: Colors.blue,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          "IMSP",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 120,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                      key: _key,
                      child: Column(
                        children: [
                          TextFormField(
                              controller: emailC,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (String? v) {
                                if (v != null && EmailValidator.validate(v)) {
                                  return null;
                                } else {
                                  return "Login invalide";
                                }
                              },
                              onSaved: (String? v) {},
                              decoration: InputDecoration(
                                  label: const Text('Login:'),
                                  hintText: "Ex: admin@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ))),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                              controller: passwordC,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) => setState(() {}),
                              obscureText: _isSecret,
                              validator: (String? v) {
                                if (v != null && v.length >= 6) {
                                  return null;
                                } else {
                                  return "Mot de passe invalide";
                                }
                              },
                              onSaved: (String? v) {},
                              decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () => setState(() {
                                      _isSecret = !_isSecret;
                                    }),
                                    child: Icon(!_isSecret
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  label: const Text('Password:'),
                                  hintText: "Ex: ............",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        const BorderSide(color: Colors.green),
                                  ))),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () => {reset()},
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    if (_key.currentState!.validate()) {
                                      _key.currentState!.save();
                                    } else {
                                      return;
                                    }

                                    retrieveTexts();
                                    String message;
                                    log.d(email);
                                    var loginCode= await Login().signIn(email!, password!);
                                    //loginCode=success;
                                    switch (loginCode) {
                                      case networkRequestFailed:
                                        message =
                                            "La requête a échoué. Vous n'êtes peut être pas connecté à internet";
                                        break;

                                      case emailNotExists:
                                        message =
                                            'Aucun admin avec une telle adresse email';
                                        break;
                                      case emailNotVerified:
                                        message =
                                            'Adresse email non vérifiée! Accédez à votre boite Gmail pour vérifier';
                                        break;

                                      case wrongPassword:
                                        message = 'Mot de passe incorrect';
                                        break;

                                      case tooManyRequests:
                                        Login().resetPassword(email!);
                                        message =
                                            "L'accès à ce compte a été temporairement désactivé en raison de nombreuses tentatives de connexion infructueuses. Vous pouvez immédiatement le restaurez en réinitialisant votre mot de passe ou vous pouvez réessayer plus tard. Un email de reinitialisation est envoyé à cette adresse";
                                        break;

                                      case success:
                                        log.d(email);
                                        if(await AdminDB().exists(email!)) {
                                          message = 'Vous êtes connecté!';

                                          reset();
                                        }
                                        else{
                                          message="Votre compte admin vient d'être supprimé car vous n'êtes plus admin";
                                        loginCode=accountDeleted;
                                        }

                                        break;

                                      default:
                                        log.d('****loginCode:$loginCode');
                                        message = '****Erreur inconnue';
                                        break;
                                    }

                                    log.d(message);

                                    showToast(message);

                                    if (loginCode == success) {
                                      //showToast(message);
                                      Future.delayed(const Duration(seconds: 3),
                                          () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return const StatistiquesForServices();
                                        }));
                                      });
                                    }
                                  },
                                  child: const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          InkWell(
                              child: Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: Colors.blue.shade400,
                                  fontSize: 20,
                                ),
                              ),
                              onTap: () async {
                                retrieveTexts();
                                String message;
                               if(await AdminDB().exists(email!)){
                                 if(await Login().resetPassword(email!)) {
                                   message =
                                 'Un email de réinitialisation de mot de passe a été envoyé à cette adresse';
                                 } else {
                                   message="Veillez reessayer";
                                 }
                               }
                               else{
                                 message="Aucun admin avec une telle adresse email";
                               }


                                log.d(message);
                                ToastUtils.showToast(context, message, 3);
                              })
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
