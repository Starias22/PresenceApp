import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/frontend/screens/admin_home_page.dart';
import 'package:presence_app/frontend/widgets/afficheAdminCard.dart';

class AfficherAdmins extends StatefulWidget {
  const AfficherAdmins({Key? key}) : super(key: key);

  @override
  State<AfficherAdmins> createState() => _AfficherAdminsState();
}

class _AfficherAdminsState extends State<AfficherAdmins> {
  late List<Admin> admins = [];
  late List<Admin> adminsAff = [];



  Future<void> retrieve() async {
    var x = await AdminDB().getAllAdmins();

    setState(() {
      admins = x;
      adminsAff = admins;
    });
  }

  @override
  void initState() {
    

    super.initState();
    retrieve();
  }

  @override
  Widget build(BuildContext context) {
    
    //adminsAff = admins;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0020FF),
        centerTitle: true,
        title: const Text(
          "Liste des admins",
          // style: TextStyle(
          //   fontSize: 23,
          // ),
        ),
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
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: SearchBar(
                hintText: 'Rechercher par nom ou prénom',

                  onChanged: (value) {
                setState(() {
                 adminsAff = admins
    .where((admin) =>
        admin.firstname.toLowerCase().contains(value.toLowerCase())
            ||
        admin.lastname.toLowerCase().contains(value.toLowerCase())
        ).toList();


                });
              }),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate(
                  List.generate(adminsAff.length, (int index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: AfficherAdminCard(admin: adminsAff[index]),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Divider(),
                )
              ],
            );
          }))),
        ],
      ),
    );
  }
}
