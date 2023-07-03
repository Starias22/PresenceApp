import 'package:presence_app/backend/firebase/firestore/presence_db.dart';

class StatisticsData{
  String timeRange;
  double percentage;
  StatisticsData(this.timeRange, this.percentage);

}

List<List<StatisticsData>> convertToDataStatistics(List<Map<String, double>>
inputMapsList) {
  List<StatisticsData> entryStatistics=[],exitStatistics=[];
  inputMapsList[0].forEach((timeRange, percentage) {
    entryStatistics.add(StatisticsData(timeRange,percentage));
  });
  inputMapsList[1].forEach((timeRange, percentage) {
    exitStatistics.add(StatisticsData(timeRange,percentage));
  });

  return [entryStatistics,exitStatistics];
}
Future<List<List<StatisticsData>>> data(String employeeId) async {

  var x=await  PresenceDB().getStatisticsInRange
    (start: DateTime(2023,6,1), end: DateTime(2023,6,30),
      employeeId: employeeId);
  var pie = convertToDataStatistics(x);

  return pie;
}