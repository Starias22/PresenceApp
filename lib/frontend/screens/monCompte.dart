
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/new_back/firestore/employee_db.dart';
import 'package:presence_app/backend/new_back/models/employee.dart';
import '../widgets/monCompteCard.dart';
import 'mesStatistiques.dart';

class MonCompte extends StatefulWidget {
   MonCompte({Key? key}) : super(key: key);

  @override
  State<MonCompte> createState() => _MonCompteState();
}

class _MonCompteState extends State<MonCompte> {
  late Employee employee;

  Future<void> retrieve() async {
    String? email=FirebaseAuth.instance.currentUser!.email;
    String? id=await EmployeeDB().getEmployeeIdByEmail(email!);
     employee=await EmployeeDB().getEmployeeById(id!);

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
        centerTitle: true,
        title: Text("Paramètres et confidentialité",
        style: TextStyle(
          fontSize: 18
        ),),

        leading: IconButton(
            onPressed: () => {Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => MesStatistiques()))},
            icon: Icon(Icons.arrow_back,)
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
              child: Text('Error retrieving employee data'),
            );
          } else {
            return CompteCard(employee: employee);
          }
        },
      )
    );
  }
}
