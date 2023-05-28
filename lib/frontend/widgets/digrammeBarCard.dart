import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class DiagrammeBarCard extends StatelessWidget {
  final List<double> percentages;
  Function(DateTime) onMonthChanged;
  
   DiagrammeBarCard({Key? key, required this.percentages,required this.onMonthChanged}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <ColumnSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: <ChartData>[
            ChartData('Présences', percentages[0], Colors.green),
            ChartData('Retards', percentages[1], Colors.yellow),
            ChartData('Absences', percentages[2], Colors.red),
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