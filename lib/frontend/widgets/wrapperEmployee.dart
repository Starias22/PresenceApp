import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/frontend/screens/employee_home_page.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final user0 = Provider.of<User?>(context);
    if(user0 == null) {
      return const Welcome();

    }
    else{
      List<UserInfo> providerData = user!.providerData;
      for(UserInfo userInfo in providerData){
        if (userInfo.providerId == 'password'){
          // return const AdminHomePage();
          return const AdminHomePage();

        }
        else{
          return const EmployeeHomePage();


        }
      }
    }
    return const Text("Quelque chose s'est mal tournée");
  }
}