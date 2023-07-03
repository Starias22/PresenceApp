import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/models/utils/service.dart';
import 'package:presence_app/frontend/services.dart';

import 'package:presence_app/frontend/widgets/servicesCard.dart';
import 'package:presence_app/utils.dart';

class ServicesManagement extends StatefulWidget {
  const ServicesManagement({Key? key}) : super(key: key);

  @override
  State<ServicesManagement> createState() => _ServicesManagementState();
}

class _ServicesManagementState extends State<ServicesManagement> {
  List<Service> services=[];

  Future<void> retrieveServices() async {
    var x=await ServiceDB().getAllServices();
    setState(() {
      services=x;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveServices();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Gestion des services"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueGrey,
              ),
              child: IconButton(
                tooltip: 'Ajouter ',
                onPressed: (){
                  showServiceDialog(context);
                },
                icon: const Icon(Icons.add, color: Colors.black, ),
              ),
            ),
          )
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate(
                List.generate(services.length, (int index) {
                  return Column(
                    children: [
                      ServicesCard(service: services[index]),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0.0),
                        child: Divider(),
                      )
                    ],
                  );
                }
                )
              )
          ),
        ],
      ),
    );
  }
}
