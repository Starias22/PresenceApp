
import '../../utils.dart';

class DataService{
  String service;
 List<double>percentages;

    DataService(this.service, this.percentages);

}
List<DataService> convertToDataService(Map<String, List<double>> inputMap) {
  return inputMap.entries.map((entry) {
    return DataService(entry.key, [entry.value[0],entry.value[1],entry.value[2] ]);
  }).toList();
}
Future<List<DataService>> data() async {
 //var x=await  PresenceManager().getMonthReportForAllServices(Day.today());
  var x=0;
 List<DataService> pie = convertToDataService(x as Map<String, List<double>>);
log.d(x);
 log.d(pie);

  return pie;
}