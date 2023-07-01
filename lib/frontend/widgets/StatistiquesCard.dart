import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/data_statististics.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatistiquesCard extends StatelessWidget {
 // List<DataService> chartData;
  late TooltipBehavior _tooltipBehavior;

  int index;
  List<DataStatistics> data;
  StatistiquesCard({Key? key,
     required this.index,required this.data}) : super(key: key){
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        //height: MediaQuery.of(context).size.height*3/4,
        child: SfCircularChart(

          legend: Legend(isVisible: true, position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap),
          tooltipBehavior: _tooltipBehavior,
          series: <CircularSeries>[
            PieSeries<DataStatistics, String>(
              dataSource: data,
              xValueMapper: (DataStatistics data,_) => data.timeRange,
              yValueMapper: (DataStatistics data,_) => data.percentage,

              dataLabelSettings: const DataLabelSettings(isVisible: true),
              enableTooltip: true,
            )
          ],
        ),
      ),
    );
  }
}
