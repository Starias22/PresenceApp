import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/utils.dart';

class DataService{
  String service;
 List<double>percentages;

    DataService(this.service, this.percentages);

}
List<DataService> convertToDataService(Map<String, List<double>> inputMap) {
  return inputMap.entries.map((entry) {
    return DataService(entry.key, [entry.value[0],
      entry.value[1],entry.value[2] ]);
  }).toList();
}
Future<List<DataService>> data() async {
  // Simulate loading delay
  await Future.delayed(const Duration(seconds: 2));
 var x=await  PresenceDB().getServicesReport();
 List<DataService> pie = convertToDataService(x);

  return pie;
}