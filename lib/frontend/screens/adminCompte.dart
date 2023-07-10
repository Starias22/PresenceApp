import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/utils.dart';
import '../../backend/firebase/firestore/admin_db.dart';
import '../../backend/models/utils/admin.dart';
import '../widgets/adminCompteCard.dart';


class AdminAccount extends StatefulWidget {
  const AdminAccount({Key? key,himself=true}) : super(key: key);

  @override
  State<AdminAccount> createState() => _AdminAccountState();
}



class _AdminAccountState extends State<AdminAccount> {
String? email=FirebaseAuth.instance.currentUser?.email;
late String id;
late Admin admin;
Future<void> retrieve() async {
  String? id=await  AdminDB().getAdminIdByEmail(email!);

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
        leading: IconButton(
            onPressed: () => {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AdminHomePage()))
                },
            icon: const Icon(
              Icons.arrow_back,
            )),
          backgroundColor: appBarColor,
          centerTitle: true,
          title: const Text("Paramètres et confidentialité",
            style: TextStyle(
                fontSize: appBarTextFontSize
            ),
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
