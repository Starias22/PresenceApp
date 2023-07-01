import 'package:presence_app/backend/firebase/firestore/presence_db.dart';

class DataStatistics{
  String timeRange;
  double percentage;
  DataStatistics(this.timeRange, this.percentage);

}

List<DataStatistics> convertToDataStatistics(Map<String, double> inputMap) {
  List<DataStatistics> statistics=[];
  inputMap.forEach((timeRange, percentage) {
    statistics.add(DataStatistics(timeRange,percentage));
  });
  return statistics;
}
Future<List<DataStatistics>> data(String employeeId) async {
  // Simulate loading delay
  //await Future.delayed(const Duration(seconds: 2));
  var x=await  PresenceDB().getEntryStatisticsInRange
    (start: DateTime(2023,6,1), end: DateTime(2023,6,30),
      employeeId: employeeId);
  List<DataStatistics> pie = convertToDataStatistics(x);

  return pie;
}