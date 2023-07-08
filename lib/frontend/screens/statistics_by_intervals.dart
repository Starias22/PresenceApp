import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/firestore/statististics_data.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/pdf.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/snack_bar.dart';
import 'package:presence_app/frontend/widgets/statistics_card.dart';
import 'package:presence_app/utils.dart';
import '../widgets/cardTabbar.dart';


class EmployeeStatisticsPerRanges extends StatefulWidget {
  String employeeId;
  String employeeName;
  DateTime startDate;

  EmployeeStatisticsPerRanges({
    Key? key,
    required this.employeeId,
    required this.employeeName,
    required this.startDate
  }) : super(key: key);

  @override
  State<EmployeeStatisticsPerRanges> createState() =>
      _EmployeeStatisticsPerRangesState();
}

class _EmployeeStatisticsPerRangesState
    extends State<EmployeeStatisticsPerRanges> {
  bool dataLoading = true;
  int _selectedIndex = 0;
  List<String> tabBars = ['Entrées', 'Sorties'];
  List<List<StatisticsData>> chartData = [];
  List<StatisticsData> chartDataAff = [];
  bool downloadInProgress=false;
 // late Employee employee;
   DateTime thisMonth=DateTime.now();
   String month='Mois Année';

   DateTime targetMonth=DateTime.now();


  void _etat(int index) async {
    chartDataAff = chartData[index];
  }

  Future<void> retrieve() async {

    DateTime today=await utils.localTime();
    thisMonth=DateTime(today.year,today.month,1);
    targetMonth=thisMonth;
    setState(() {
      month=utils.getMonthAndYear(targetMonth);
    });

  }
  @override
  void initState() {
    super.initState();
    retrieve();

    data(widget.employeeId,targetMonth).then((x) {
      if (mounted) {
        setState(() {
          chartData = x;
          chartDataAff = chartData[_selectedIndex];
          dataLoading = false;
        });
      }
    });
  }

  Future<void> onMonthChanged({required bool previous}) async {

    log.d('start date: ${widget.startDate}');
 if(
 (!previous &&targetMonth.isAtSameMomentAs(thisMonth))
     ||
     (previous &&targetMonth.isAtSameMomentAs(
         DateTime(widget.startDate.year,
             widget.startDate.month
         ))
     )
 ){

   ScaffoldMessenger.of(context).showSnackBar(
       CustomSnackBar(
         showCloseIcon: true,
           message: 'Limite déjà atteinte!',
         simple: true,
         duration: const Duration(seconds: 2),

       )
   );

   return;
 }
    log.d('Target month before: $targetMonth');
    targetMonth=
        DateTime(targetMonth.year,

            previous?targetMonth.month
                -1:targetMonth.month+1);
    log.d('Target month after: $targetMonth');
    setState(() {
      month=utils.getMonthAndYear(targetMonth);
      dataLoading=true;
    });

    var x=convertToDataStatistics
      (await PresenceDB().getMonthlyStatisticsInRange(targetMonth,
        widget.employeeId)) ;

    setState(() {
      chartData=x;
    chartDataAff=chartData[_selectedIndex];
    dataLoading=false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: const Text(
            "Statistiques par intervalles",
          ),
          centerTitle: true,
          actions: [
            if (!dataLoading &&
                chartData[0].isNotEmpty&&
                chartData[1].isNotEmpty
            )
              IconButton(
                tooltip: 'Enregistrer comme PDF',
                icon: downloadInProgress?
                const CircularProgressIndicator() :
                 const Icon(Icons.download, color: Colors.white,
        size: 30,),
                onPressed: () async {

                  setState(() {
                    downloadInProgress=true;
                  });

                  await ReportPdf().statisticsPerRanges(
                      widget.employeeName, chartData,month);
                  setState(() {
                    downloadInProgress=false;
                  });
                    },
              ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: Colors.white,
              title: Container(
                height: 100.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: TabBar(
                  tabs: List.generate(tabBars.length, (index) {
                    if (_selectedIndex == index) {
                      return CustomTab(
                        text: tabBars[index],
                        isSelected: true,
                      );
                    } else {
                      return CustomTab(text: tabBars[index]);
                    }
                  }),
                  isScrollable: true,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _etat(_selectedIndex);
                    });
                  },
                  indicatorColor: Colors.blueGrey.shade50,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomElevatedButton(
                    text: 'Précédent',
                    onPressed: ()
                    async {
                      onMonthChanged(previous: true);

                    },
                  ),
                   Text(
                    month,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),

                    CustomElevatedButton(
                    text: 'Suivant',
                    onPressed: ()
                    {
                      onMonthChanged(previous: false);
                    },
                  ),
                ],
              ),
                  dataLoading? const Center(child: CircularProgressIndicator()):
                    StatisticsCard(entryOrExitData: chartDataAff),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
