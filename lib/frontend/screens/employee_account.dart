import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/employee_home_page.dart';
import 'package:presence_app/frontend/widgets/monCompteCard.dart';
import 'package:presence_app/utils.dart';



class EmployeeAccount extends StatefulWidget {
   const EmployeeAccount({Key? key}) : super(key: key);

  @override
  State<EmployeeAccount> createState() => _EmployeeAccountState();
}

class _EmployeeAccountState extends State<EmployeeAccount> {
  late Employee employee;


  Future<void> retrieve() async {
    String? email;
    email=FirebaseAuth.instance.currentUser!.email;

     employee=await EmployeeDB().getEmployeeByEmail(email!);

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieve();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text("Mon compte",
        style: TextStyle(
          fontSize: appBarTextFontSize
        ),),

        leading: IconButton(
            onPressed: () => {

              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => const EmployeeHomePage()))

            },
            icon: const Icon(Icons.arrow_back,)
        ),
      ),

      body:FutureBuilder<void>(
        future: retrieve(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Une erreur s'est produite"),
            );
          } else {
            return CompteCard(employee: employee);
          }
        },
      )
    );
  }
}
