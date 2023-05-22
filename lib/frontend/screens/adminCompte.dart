import 'package:flutter/material.dart';
import '../../backend/models/admin.dart';
import '../screens/pageStatistiques.dart';
import '../widgets/adminCompteCard.dart';


class AdminCompte extends StatefulWidget {
  const AdminCompte({Key? key}) : super(key: key);

  @override
  State<AdminCompte> createState() => _AdminCompteState();
}

class _AdminCompteState extends State<AdminCompte> {

  late Admin admin = Admin.target('adedeezechiel@gmail.com.com');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Paramètres et confidentialité",
            style: TextStyle(
                fontSize: 18
            ),),

          leading: IconButton(
              onPressed: () => {Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => const StatistiquesForServices()))},
              icon: const Icon(Icons.arrow_back,)
          ),
        ),

        body: CompteCard(admin: admin)
    );
  }
}
