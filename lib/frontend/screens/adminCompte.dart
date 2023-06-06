import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/utils.dart';

import '../../backend/firebase/firestore/admin_db.dart';
import '../../backend/models/admin.dart';
import '../screens/pageStatistiques.dart';
import '../widgets/adminCompteCard.dart';


class AdminCompte extends StatefulWidget {
  const AdminCompte({Key? key}) : super(key: key);

  @override
  State<AdminCompte> createState() => _AdminCompteState();
}



class _AdminCompteState extends State<AdminCompte> {
String? email=FirebaseAuth.instance.currentUser?.email;
late String id;
late Admin admin;
Future<void> retrieve() async {
  String? id=await  AdminDB().getAdminIdByEmail(email!);

  log.i('the id: $id');
  admin= await AdminDB().getAdminById(id!);
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
          title: const Text("Paramètres et confidentialité",
            style: TextStyle(
                fontSize: 18
            ),),

          leading: IconButton(
              onPressed: () => {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => const StatistiquesForServices()))
              },
              icon: const Icon(Icons.arrow_back,)
          ),
        ),

    body: FutureBuilder<void>(
    future: retrieve(),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(
    child: CircularProgressIndicator(),
    );
    } else if (snapshot.hasError) {
    return const Center(
    child: Text('Error retrieving admin data'),
    );
    } else {
    return CompteCard(admin: admin);
    }
    },
    )
    );
  }
}
