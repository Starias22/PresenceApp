import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:presence_app/backend/models/day.dart';
import 'package:presence_app/backend/models/employee.dart';



class DiagrammeBarCard extends StatelessWidget {
  final List<double> porcent;
   DiagrammeBarCard({Key? key, required this.porcent}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ColumnSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: <ChartData>[
            ChartData('Présences', porcent[0], Colors.green),
            ChartData('Retards', porcent[1], Colors.yellow),
            ChartData('Absences', porcent[2], Colors.red),
          ],
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
        )
      ],
    );
  }
}



class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}