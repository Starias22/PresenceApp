import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/day.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/presence_manager.dart';
import '../screens/mesStatistiques.dart';
import 'digrammeBarCard.dart';

class DiagrammeBar extends StatefulWidget {
  const DiagrammeBar({Key? key}) : super(key: key);

  @override
  State<DiagrammeBar> createState() => _DiagrammeBarState();
}

class _DiagrammeBarState extends State<DiagrammeBar> {
  List<List<double>> p = [];
  List<double> counts = [];
  Future<void> retrieve() async {
    String? email = FirebaseAuth.instance.currentUser!.email;
    var employee = Employee.target(email!);
    var x = await PresenceManager().count(employee, Day.today());
    setState(() {
      counts = x;
       p = [
     [20,10,23],   //[...counts], // Create a new instance of the counts list
     [45,20,13],   //[...counts], // Create another new instance of the counts list
      [20,15,30]  //[...counts] // Create yet another new instance of the counts list
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    retrieve();
  }

  int index = 0;

  //late List<Map<String, List<double>>> data;

  void _previousChart() {
    setState(() {
      if (index > 0) {
        index--;
      }
    });
  }

  void _nextChart() {
    setState(() {
      if (index < p.length - 1) {
        index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<double> poucent = p[index];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Statistiques du mois",
          style: TextStyle(
            fontSize: 23,
          ),
        ),
        leading: IconButton(
            onPressed: () => {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MesStatistiques()))
                },
            icon: const Icon(
              Icons.arrow_back,
            )),
      ),
      body: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      print("On m'a appuyé");
                      _previousChart();
                    }),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
                InkWell(
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    _nextChart();
                    print("On m'a appuyé");
                  },
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: DiagrammeBarCard(porcent: poucent)))),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
