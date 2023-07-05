import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/statististics_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsCard extends StatelessWidget {
  late TooltipBehavior _tooltipBehavior;

  List<StatisticsData>  entryOrExitData;
  StatisticsCard({Key? key,
     required this.entryOrExitData}) : super(key: key){
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    if(entryOrExitData.isEmpty) return const Text('Aucune donnée correspondante');
    return SafeArea(
      child: SizedBox(
        //height: MediaQuery.of(context).size.height*3/4,
        child: SfCircularChart(

          legend: Legend(isVisible: true, position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap),
          tooltipBehavior: _tooltipBehavior,
          series: <CircularSeries>[
            PieSeries<StatisticsData, String>(
              dataSource: entryOrExitData,
              xValueMapper: (StatisticsData data,_) => data.timeRange,
              yValueMapper: (StatisticsData data,_) => data.percentage,
              // dataLabelSettings: const DataLabelSettings(
              //   isVisible: true,
              //   labelPosition: ChartDataLabelPosition.outside,
              //   labelIntersectAction: LabelIntersectAction.none,
              //
              // ),
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              enableTooltip: true,
            )
          ],
        ),
      ),
    );
  }
}
