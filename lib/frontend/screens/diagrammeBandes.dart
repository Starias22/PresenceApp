import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import '../../backend/firebase/firestore/presence_db.dart';
import '../../backend/models/employee.dart';
import '../../utils.dart';
import '../screens/mesStatistiques.dart';
import '../widgets/digrammeBarCard.dart';

class DiagrammeBar extends StatefulWidget {
  String?email;
   DiagrammeBar({Key? key,this.email}) : super(key: key);

  @override
  State<DiagrammeBar> createState() => _DiagrammeBarState();
}

class _DiagrammeBarState extends State<DiagrammeBar> {
  late DateTime  date;
  late DateTime thisMonth;
late String email;

  
  late DateTime startDate;
  late List<double> x = [];
  late Employee employee;
  bool isLoading = true;
  String? id;
  List<double> percentages = [];

  Future<void> retrieve() async {
   email=(widget.email ?? FirebaseAuth.instance.currentUser!.email)!;

    DateTime now=await utils.localTime();
    thisMonth=DateTime(now.year,now.month);
    date=thisMonth;
    employee = await EmployeeDB().getEmployeeByEmail(email);

   if( employee.status==EStatus.pending) {
     x=[0,0,0];
     ToastUtils.showToast(context, 'Employé en attente', 5);
     //return;
   }
    startDate = employee.startDate;
    startDate=DateTime(startDate.year,startDate.month);
    if (!const ListEquality<double>().equals(x,[0,0,0])) {
      x = await PresenceDB().getCount(id!, date);
    }

   log.d('x:::$x');



    setState(() {
      percentages = x;
    });
  }

  Future<void> onMonthChanged(DateTime newMonth) async {

    log.d('Month changed');
    setState(() {
      isLoading = true;
    });

    var newEventsData = await PresenceDB().getCount(id!, newMonth);
    setState(() {
      percentages = newEventsData;
      log.i('data:$percentages');
      isLoading = false;
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
        centerTitle: true,
        title: const Text(
          "Statistiques du mois",
          style: TextStyle(
            fontSize: 23,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MesStatistiques(email: email),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
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
                    onTap: () async {
                      if(startDate.isBefore(date)) {
                        date = DateTime(date.year,
                          date.month - 1);
                        onMonthChanged(date);
                      }
                      else{
                        log.d('Limit reached');
                      }
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                  ),
                  InkWell(
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                    ),
                    onTap: () async {
                      if(thisMonth.isAfter(date)) {
                        date = DateTime(date.year,
                            date.month + 1);
                        onMonthChanged(date);
                      }
                      else{
                        log.d('Limit reached');
                      }
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
                  child:
                  percentages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : DiagrammeBarCard(
                    percentages: percentages,
                    onMonthChanged: onMonthChanged,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
