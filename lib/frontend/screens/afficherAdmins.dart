import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/pageStatistiques.dart';


import '../../new_back/firestore/admin_db.dart';
import '../../new_back/models/admin.dart';
import '../../utils.dart';
import '../widgets/afficheAdminCard.dart';

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
        centerTitle: true,
        title: const Text(
          "Liste des admins",
          style: TextStyle(
            fontSize: 23,
          ),
        ),
        leading: IconButton(
            onPressed: () => {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const StatistiquesForServices()))
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
              child: SearchBar(onChanged: (value) {
                setState(() {
                 adminsAff = admins
    .where((admin) =>
        admin.firstname.toLowerCase().contains(value.toLowerCase())||
        admin.lastname.toLowerCase().contains(value.toLowerCase())
        //admin.getEmail().toLowerCase().contains(value.toLowerCase())
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
