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
  late List<Admin> admins = [];
  late List<Admin> allAdmins ;
  late List<Admin> adminsAff = [];


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
        body: FutureBuilder<void>(
        future: retrieve(),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
    if (inProgress) {
    return const Center(
    child: CircularProgressIndicator(),
    );
    }
    else if (snapshot.hasError) {
    return const Center(
    child: Text('Error retrieving admin data'),
    );
    }
    else if(allAdmins.isEmpty){
    return const Center(child: Text('Aucun admin enregistré'));
    }
    else {
      return CustomScrollView(
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
      );
    }
        },
        )
    );
  }
}
