import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/acceuilAdmin.dart';
import 'package:presence_app/frontend/screens/homePageUser.dart';
import 'package:presence_app/frontend/screens/image.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final _user = Provider.of<User?>(context);
    if(_user == null) {
      return const WelcomeImsp();
      print("Aucun utilisateur connecté");
    }
    else{
      List<UserInfo> providerData = user!.providerData;
      for(UserInfo userInfo in providerData){
        if (userInfo.providerId == 'password'){
          return const HomePageOfAdmin();
          print("Page d'acceuil des admins");
        }
        else{
          return const HomePage();
          //return ButtonWidget();
          print("Page d'acceuil des employés");
        }
      }
    }
    return Container(
      child: const Text("Quelque chose s'est mal tournée"),
    );
  }
}