import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/models/utils/service.dart';
import 'package:presence_app/frontend/services.dart';
import 'package:presence_app/frontend/widgets/service_card.dart';
import 'package:presence_app/utils.dart';

class HandleHolidays extends StatefulWidget {
  const HandleHolidays({Key? key}) : super(key: key);

  @override
  State<HandleHolidays> createState() => _HandleHolidaysState();
}

class _HandleHolidaysState extends State<HandleHolidays> {
  List<Service> services=[];

  Future<void> retrieveServices() async {
    var x=await ServiceDB().getAllServices();
    setState(() {
      services=x;
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveServices();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Gestion des congés",
          style: TextStyle(
              fontSize: appBarTextFontSize
          ),),
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
                        ServiceCard(service: services[index]),
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
