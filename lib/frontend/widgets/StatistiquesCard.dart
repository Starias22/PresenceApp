import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../backend/geo/modele/service.dart';


class StatistiquesCard extends StatelessWidget {
  List<DataService> chartData;
  late TooltipBehavior _tooltipBehavior;

  StatistiquesCard({Key? key, required this.chartData}) : super(key: key){
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  //LocalBdManager localBdManager = LocalBdManager();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: SizedBox(
          height: MediaQuery.of(context).size.height*3/4,
          child: SfCircularChart(

            //title: ChartTitle(text: "Statistiques par service"),
            legend: Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
            tooltipBehavior: _tooltipBehavior,
            series: <CircularSeries>[
              PieSeries<DataService, String>(
                dataSource: chartData,
                xValueMapper: (DataService data,_) => data.service,
                yValueMapper: (DataService data,_) => data.poucent,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                enableTooltip: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
