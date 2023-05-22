
import 'package:flutter/material.dart';
import '../../backend/models/employee.dart';
import '../widgets/monCompteCard.dart';
import 'mesStatistiques.dart';

class MonCompte extends StatefulWidget {
   MonCompte({Key? key}) : super(key: key);

  @override
  State<MonCompte> createState() => _MonCompteState();
}

class _MonCompteState extends State<MonCompte> {

  late Employee employee=Employee('mail', 'fname', 'lname', 'gender');

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

      body: CompteCard(employee: employee)
    );
  }
}
