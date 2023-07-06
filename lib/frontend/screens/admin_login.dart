// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/frontend/screens/bottom_nav_bar.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';


import 'package:presence_app/utils.dart';

import '../../backend/firebase/firestore/admin_db.dart';
import '../../backend/firebase/login_service.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({Key? key}) : super(key: key);

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool loginInProcess = false;
  final _key = GlobalKey<FormState>();
  bool _isSecret = true;

  TextEditingController emailC = TextEditingController(),
      passwordC = TextEditingController();

  String? email, password;
  bool emailSending=false;



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
        extendBodyBehindAppBar: true,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEEF0FF),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Entrez vos identifiants !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height/3,
                    child: Center(
                      child: Image.asset('assets/images/blob.png', fit: BoxFit.cover,),
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
                                  contentPadding: const EdgeInsets.symmetric(vertical: 3),
                                  filled: true,
                                  fillColor: const Color(0xFFEEF0FF),
                                  label: const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text('Login:'),
                                  ),
                                  hintText: "Ex: admin@gmail.com",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
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
                                  contentPadding: const EdgeInsets.symmetric(vertical: 3),
                                  filled: true,
                                  fillColor: const Color(0xFFEEF0FF),
                                  suffixIcon: InkWell(
                                    onTap: () => setState(() {
                                      _isSecret = !_isSecret;
                                    }),
                                    child: Icon(!_isSecret
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                  label: const Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Text('Password:'),
                                  ),
                                  hintText: "Ex: ............",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
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
                             if(!loginInProcess) ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
                                ),
                                onPressed: () => {
                                  reset(),
                                  Navigator.of(context).pop()
                                },
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              loginInProcess ? const Center(child: CircularProgressIndicator(),) :   ElevatedButton(
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
                                    setState(() {
                                      loginInProcess=true;
                                    });
                                    retrieveTexts();
                                    

                                    await singIn();
                                  },
                                  child: const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                        color: Colors.white,
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                         emailSending?
                         const CircularProgressIndicator(): InkWell(
                              child: const Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  emailSending=true;
                                });
                                retrieveTexts();
                                String message;


        if (await Connectivity().checkConnectivity()== ConnectivityResult.none) {
    message='Aucune connexion internet';
      }
                              else if(await AdminDB().exists(email!)){

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
                               setState(() {
                                 emailSending=false;
                               });

                                ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
                                  simple: true,
                                  showCloseIcon: false,
                                  duration: const Duration(seconds: 3) ,
                                  //width: MediaQuery.of(context).size.width-2*10,
                                  message:message ,
                                ));

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

  Future<void> singIn() async{

    var loginCode= await Login().signIn(email!, password!);

    try {


      if (await Connectivity().checkConnectivity()== ConnectivityResult.none) {
        setState(() {
          loginInProcess = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
          simple: true,
          showCloseIcon: false,
          duration: const Duration(seconds: 3) ,
          //width: MediaQuery.of(context).size.width-2*10,
          message:'Aucune connexion internet!' ,
        ));


        return;
      }

        String message;
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
          //loginCode==success;
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
              message = 'Connexion réussie !';

              reset();
            }
            else{
              message="Votre compte admin vient d'être supprimé car vous n'êtes plus admin";
              loginCode=accountDeleted;
            }
            log.d('message: $message');
            loginInProcess = false;

            break;

          default:
            loginInProcess = false;
            message = '****Erreur inconnue';
            break;
        }
      setState(() {
        loginInProcess=false;
      });

      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: false,
        duration: const Duration(seconds: 3) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:message ,
      ));




      if (loginCode == success) {
          loginInProcess = false;
          Future.delayed(const Duration(seconds: 5),
                  () {
                Navigator.push(context,
                    MaterialPageRoute(builder:
                        (BuildContext context) {
                          return const AppBarExample();
                    }));
              });
        }


    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: false,
        duration: const Duration(seconds: 3) ,
        //width: MediaQuery.of(context).size.width-2*10,
        message:"Une erreur s'est produite lors de la connexion" ,
      ));


    }
  }
}
