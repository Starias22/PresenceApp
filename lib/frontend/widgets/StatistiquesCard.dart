import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../backend/new_back/service.dart';


class StatistiquesCard extends StatelessWidget {
  List<DataService> chartData;
  late TooltipBehavior _tooltipBehavior;
  
  int index;

  StatistiquesCard({Key? key, required this.chartData,required this.index}) : super(key: key){
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height*3/4,
        child: SfCircularChart(


          legend: Legend(isVisible: true, position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap),
          tooltipBehavior: _tooltipBehavior,
          series: <CircularSeries>[
            PieSeries<DataService, String>(
              dataSource: chartData,
              xValueMapper: (DataService data,_) => data.service,
              yValueMapper: (DataService data,_) => data.percentages[index],

              dataLabelSettings: const DataLabelSettings(isVisible: true),
              enableTooltip: true,
            )
          ],
        ),
      ),
    );
  }
}
