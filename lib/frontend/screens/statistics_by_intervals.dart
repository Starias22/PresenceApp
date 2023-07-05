import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/statististics_data.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/screens/pdf.dart';
import 'package:presence_app/frontend/widgets/statistics_card.dart';
import 'package:presence_app/utils.dart';
import '../widgets/cardTabbar.dart';
import 'package:pdf/widgets.dart' as pw;


class EmployeeStatisticsPerRanges extends StatefulWidget {
  late String employeeId;
  EmployeeStatisticsPerRanges({
    Key? key,
    required this.employeeId,
  }) : super(key: key);

  @override
  State<EmployeeStatisticsPerRanges> createState() =>
      _EmployeeStatisticsPerRangesState();
}

class _EmployeeStatisticsPerRangesState
    extends State<EmployeeStatisticsPerRanges> {
  final GlobalKey _globalKey = GlobalKey();
  bool dataLoading = true;
  int _selectedIndex = 0;
  List<String> tabBars = ['Entrées', 'Sorties'];
  List<List<StatisticsData>> chartData = [];
  List<StatisticsData> chartDataAff = [];
  bool downloadInProgress=false;
  late Employee employee;

  void _etat(int index) async {
    chartDataAff = chartData[index];
  }

  @override
  void initState() {
    super.initState();

    data(widget.employeeId).then((x) {
      if (mounted) {
        setState(() {
          chartData = x;
          chartDataAff = chartData[0];
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
          title: const Text(
            "Statistiques par intervalles",
          ),
          centerTitle: true,
          actions: [
            if (!dataLoading)
              IconButton(
                tooltip: 'Enregistrer comme PDF',
                icon: downloadInProgress? const CircularProgressIndicator() :
                const Icon(Icons.download, color: Colors.black),
                onPressed: () async {
                  setState(() {
                    downloadInProgress=true;
                  });

                    var employee=await EmployeeDB().
                    getEmployeeById(widget.employeeId);
                  await ReportPdf().statisticsPerRanges(
                      '${employee.lastname} ${employee.firstname}', chartData);
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
              child: RepaintBoundary(
                key: _globalKey,
                child: Column(
                  children: [
                    if (dataLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      StatisticsCard(entryOrExitData: chartDataAff),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
