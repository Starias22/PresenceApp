// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/statististics_data.dart';
import 'package:presence_app/frontend/widgets/statistics_card.dart';
import 'package:presence_app/utils.dart';
import '../widgets/cardTabbar.dart';

class EmployeeStatisticsPerRanges extends StatefulWidget {
  late String employeeId;
   EmployeeStatisticsPerRanges({Key? key,
    required this.employeeId}) : super(key: key);

  @override
  State<EmployeeStatisticsPerRanges> createState() =>
      _EmployeeStatisticsPerRangesState();
}

class _EmployeeStatisticsPerRangesState extends
State<EmployeeStatisticsPerRanges> {



  bool dataLoading = true;

  int _selectedIndex = 0;

  List<String> tabBars = ['Entrées', 'Sorties'];
  List< List<StatisticsData>> chartData = [];
  List<StatisticsData> chartDataAff = [];


  void _etat(int index) async {
    chartDataAff = chartData[index];

  }



  @override
  void initState() {
    super.initState();

    data(widget.employeeId).then((x) {


      if(mounted) {
        setState(() {
          chartData = x;
          chartDataAff=chartData[0];
          dataLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          //automaticallyImplyLeading: false,
          title: const Text(
            "Statistiques par intervalles",
            // style: TextStyle(
            //   fontSize: 20,
            // ),
          ),
          centerTitle: true,
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
                  //controller: _tabController,
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
                   if (dataLoading) // Show circular progress indicator if data is loading
                   const Center(child: CircularProgressIndicator())

                   else
                  StatisticsCard(entryOrExitData:chartDataAff),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

