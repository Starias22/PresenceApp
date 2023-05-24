import 'package:presence_app/backend/services/planning_manager.dart';
import 'package:presence_app/backend/services/presence_manager.dart';

import '../../../utils.dart';
import '../../models/day.dart';

class DataService{
  String service;
 List<double>poucent;
  //String serviceColor;


  DataService(this.service, this.poucent);

}
List<DataService> convertToDataService(Map<String, List<double>> inputMap) {
  return inputMap.entries.map((entry) {
    return DataService(entry.key, [entry.value[0],entry.value[1],entry.value[2] ]);
  }).toList();
}
Future<List<DataService>> data() async {
 var x=await  PresenceManager().getMonthReportForAllServices(Day.today());
 List<DataService> pie = convertToDataService(x);
log.d(x);
 log.d(pie);

  return pie;
}