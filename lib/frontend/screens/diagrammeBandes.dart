import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/day.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/backend/services/presence_manager.dart';
import '../../utils.dart';
import '../screens/mesStatistiques.dart';
import '../widgets/digrammeBarCard.dart';


class DiagrammeBar extends StatefulWidget {
  const DiagrammeBar({Key? key}) : super(key: key);

  @override
  State<DiagrammeBar> createState() => _DiagrammeBarState();
}

class _DiagrammeBarState extends State<DiagrammeBar> {
  late Day addDate;
  late List<double>x=[];
 late Employee employee;
 // List<double> counts = [];
  List<double> poucent=[];
  Future<void> retrieve() async {
    String? email = FirebaseAuth.instance.currentUser!.email;
    employee = Employee.target(email!);
    await EmployeeManager().fetch(employee);
    addDate=employee.getAddDay();
    x = await PresenceManager().count(employee, Day.today());
    setState(() {
      poucent=x;

    });
  }

  @override
  void initState() {
    super.initState();
    retrieve();
  }

  int index = 0;

  int a = Day.today().getYear();
  late int b = addDate.getYear(),
      m_courant = Day.today().getMonth(),
      m_debut = addDate.getMonth();

  Future<void> _previousChart() async {
    log.d('Access previous month');
    setState(()  {
      if(b < a)
      {
        if(m_courant > 1) {
          m_courant--;
        }
        if(m_courant == 1)
        {
          m_courant=12; a--;
        }
      }
      if(a==b){
        if(m_debut < m_courant) {
          m_courant--;
        }
      }


    });
    Day day=Day.day(a,m_courant,1);
    x = await PresenceManager().count(employee, day);
  }

  Future<void> _nextChart() async {
    log.d('Access next month');
    setState(()  {
     if(a<Day.today().getYear()){
       if(m_courant<12) {
         m_courant++;
       }
       if(m_courant==12){
         m_courant=1;
         a++;
       }

     }

     if(a==Day.today().getYear()){
       if(m_courant<Day.today().getMonth()){
         m_courant++;
       }
     }

    });
    Day day=Day.day(a,m_courant,1);
    x = await PresenceManager().count(employee, day);
  }

  @override
  Widget build(BuildContext context) {
poucent=x;
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
                    onTap: () async {
                      log.d('///////////////Before call to previous');
                      await _previousChart();
                      log.d('//////////////After call to previous');
                    }),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
                InkWell(
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blue,
                  ),
                  onTap: () async {
                    log.d('///////////////Before call to next chart');
                   await  _nextChart();
                    log.d('/////////////After call to next chart');
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
