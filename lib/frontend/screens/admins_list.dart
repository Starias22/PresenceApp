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



  bool inProgress=true;
  Future<void> retrieve() async {
    var x = await AdminDB().getAllAdmins();

    setState(() {
      admins = x;
      allAdmins=admins;
      adminsAff = admins;
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
         // adminsAff.isEmpty? const Text('Aucun admin correspondant'):
         SliverList(
              delegate: SliverChildListDelegate(
                  List.generate(adminsAff.length, (int index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: AdminDisplayCard(admin: adminsAff[index]),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Divider(),
                )
              ],
            );
          }))),
        ],
      )
      ,

    );
  }
}
