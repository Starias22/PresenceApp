import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/backend/models/service.dart';
import 'package:presence_app/backend/services/day_manager.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/backend/services/service_manager.dart';
import 'package:presence_app/utils.dart';

import '../models/day.dart';
import '../models/presence.dart';
import '../new_back/models/employee.dart';

class PresenceManager {
  late DatabaseReference _ref;
  final pre = "presence";

 PresenceManager() {
    _ref = FirebaseDatabase.instance.ref('${pre}s');
  }

  Future<int> getCount() async {
    var data = await getData();
    //log.i('data: $data');

    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, pre);
  }

  Future<int> create(Presence presence) async {
    //log.i('val:${presence.isValid()}');

    if (!presence.isValid()) {
      //log.e('Invalid presence');

      return invalidPresence;
    }

    if (await exists(presence) == presenceExists) {
      
      return presenceExists;
    }
    _ref.child('$pre${await getNextNum()}').set(presence.toMap());
    //log.d('presence created successfully');

    return success;
  }

  Future<int> exists(Presence presence) async {
   return 0;
  }

  Future<int> fetch(Presence presence) async {
    /*if (!presence.hasValidEmail()) {
      log.e('Invalid email');*/

      return invalidEmail;
    }


  }



  dynamic getData() async {


}
  void clear() {



  Future<List<double>> getMonthReportForAService(Service service, Day day)
  async {

    List<int> sum;
    var employees=await EmployeeManager().getData() as Map;
    //log.e('//////');
    int count=0;
    employees.forEach((key, value) {
      if(value['service']==service.getName()) {
        count++;
      }
    });


    //log.d('There are  $count employees in the ${service.getName()} service');
    int last=
    day.equals(Day.today())?day.getDayOfMonth():day.getLengthOfMonth();
    List<List<int>> report=[];
    Day d;

    for(var i=1;i<=last;i++){
      d=Day.day(day.getYear(),day.getMonth(),i);
     //report.add(await getDailyReportCounts(service, d));

     //log.e('Okay');

    }
    //log.d('Let us continue');
    count*=await DayManager().getMonthWorkdaysCount(day);
  //log.d('counts***$count');
   sum=  utils.sum(report);
   //log.d('sum***$sum');
   List<double> percents=[];
   for(int i=0;i<sum.length;i++)
     {
       percents.add((100*sum[i]/count).round() as double);
     }
   log.i('percents:$percents');
   return percents;
  }

  Future<Map<String, List<double>>> getMonthReportForAllServices(Day day) async {
    Map<String, List<double>> report = {};
    String service;
    var services = await ServiceManager().getData() as Map;

    for (var entry in services.entries) {
      service = entry.value['name'];

      log.e(service);

      report[service] = await getMonthReportForAService(Service(service), day);

    }

    return report;
  }


  /*Future<List<double>> count(Employee employee, Day day) async {
    int late = 0, absent = 0, present = 0;

    //var data = await getMonthReport(employee, day);
    var data={};

    int length = await DayManager().getMonthWorkdaysCount(day);

    data.forEach((date, status) {


      if (status == EStatus.present) {
        present++;
      } else if (status == EStatus.absent) {
        absent++;
      } else if (status == EStatus.late) {
        late++;
      }
    });
    return [100*present / length, 100*late / length, 100*absent / length];
  }*/

  Future<void> testAll() async {
    log.d('****');
    var report= await getMonthReportForAllServices(Day.today());

    log.e('/****');
    log.i(report);
    log.d('In this month***');
    report.forEach((key, value) {
      log.i('In the $key service there are');
      log.i('${value[0]}% of presence(s)');
      log.i('${value[1]}% of late(s)');
      log.i('${value[2]}% of absences(s)');

    });
  }

 Future<List<int>>getDailyReportCounts(Service service, Day day) async {

    var data=await getData();
    int presence=0,late=0,absence=0;
    (data as Map).forEach((node, children) {
      if(children['day']==day.getDate()&&
          children['employee']['service']==service.getName() ){

//log.d('//////////////');
            if(utils.convertES(children['status'])==EStatus.present) {
              presence++;
            }
            else if(utils.convertES(children['status'])==EStatus.late) {
             late++;
            }
            else if(utils.convertES(children['status'])==EStatus.absent) {
              absence++;
            }
                }
    });

    return [presence,late,absence];
  }


  }


  Future<void> test2(String service) async {

    log.d('The start point');
    //var x=await getMonthReportForAService(Service(service), Day.today());
var x=[];
    log.i('In this month for the $service service there are :');
    log.i('${x[0]}% of presence(s)');
    log.i('${x[1]}% of late(s)');
    log.i('${x[2]}% of absences(s)');
    log.i('${x[0]+x[1]+x[2]}% as sum of percentages');


  }

  Future<void> testMonthReport(String email) async {
   /* Employee employee = Employee.target(email);
    var report = await getMonthReport(employee, Day.today());
    log.i('report:$report');

    report.forEach((key, value) {
      log.i('date:$key status:$value');
    });*/
  }

  Future<void> tests(String service) async {
    /*var x=await getDailyReportCounts(Service(service), Day.today());
    log.d('Test****');
    log.i('The 2023-05-23, in the $service service there are :');
    log.i('${x[0]} presence(s)');
    log.i('${x[1]} late(s)');
    log.i('${x[2]} absences(s)');*/
  }

  Future<void> testCount() async {
    /*var data=await count(Employee.target('ezechieladede@gmail.com'), Day.today());
double sum=0;
    for(var item in data) {
      sum+=item;
      log.i(item);*/
    }





