import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/admin_db.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/frontend/widgets/admin_display_card.dart';
import 'package:presence_app/utils.dart';

class AdminsList extends StatefulWidget {
  const AdminsList({Key? key}) : super(key: key);

  @override
  State<AdminsList> createState() => _AdminsListState();
}

class _AdminsListState extends State<AdminsList> {
  late List<Admin> admins ;
  late List<Admin> allAdmins ;
  late List<Admin> adminsAff;
  late String currentAdminEmail;



  bool inProgress=true;
  Future<void> retrieve() async {
    var x = await AdminDB().getAllAdmins();
    String? y=FirebaseAuth.instance.currentUser?.email;


    setState(() {
      admins = x;
      allAdmins=admins;
      adminsAff = admins;
      currentAdminEmail=y!;
      inProgress=false;
    });
  }

  @override
  void initState() {
    super.initState();
    retrieve();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text(
          "Liste des admins",
           style: TextStyle(
           fontSize: appBarTextFontSize,
          ),
        ),

      ),
        body: inProgress?const Center(
          child: CircularProgressIndicator(),
        )

        : admins.isEmpty
    ? const Center(child: Text('Aucun admin enregistré'))
        : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: SearchBar(
                hintText: 'Rechercher par nom ou prénom',

                  onChanged: (value) {
                  value=value.trim();
      if (value.isEmpty||value.contains(' ')) {
      // Show all admins when the search query is empty
        setState(() {
          adminsAff = allAdmins;
        });

      }
else {
      setState(() {
      adminsAff = admins
          .where((admin) =>
      admin.firstname.toLowerCase().contains(value.toLowerCase())
      ||
      admin.lastname.toLowerCase().contains(value.toLowerCase())
      ).toList();


      }
      );
      }
              }
              ),

            ),
          ),

         SliverList(
              delegate: SliverChildListDelegate(
                  List.generate(adminsAff.length, (int index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: AdminDisplayCard(admin: adminsAff[index],
                  himself: currentAdminEmail==adminsAff[index].email,),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Divider(),
                )
              ],
            );
          }))
         ),
        ],
      ),

    );
  }
}
