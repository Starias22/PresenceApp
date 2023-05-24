import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/service.dart';
import 'package:presence_app/backend/services/day_manager.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/backend/services/service_manager.dart';
import 'package:presence_app/utils.dart';

import '../models/day.dart';
import '../models/presence.dart';

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
    if (!presence.isValid()) {
      return invalidPresence;
    }
    int test = presenceNotExists;
    var data = await getData();

    //log.i(data);

    if (data != false) {
      (data as Map).forEach((node, children) {
        if (Employee.target(children['employee']['email'])
                .equals(presence.getEmployee()) &&
            (Day(children['day'])).equals(presence.getDay())) {
          test = presenceExists;
         // log.d('Ok that presence tree exists');

          return;
        }
      });
    }
    return test;
  }

  /*Future<int> fetch(presence presence) async {
    if (!presence.hasValidEmail()) {
      log.e('Invalid email');

      return invalidEmail;
    }

    var data = await getData();

    log.i('Not prety?$data');

    if (data == false) return emailNotExists;

    (data as Map).forEach((node, childs) {
      if (childs['email'] == presence.getEmail()) {
        presence.setFname(childs['firstname']);
        presence.setLname(childs['lastname']);
        log.d('Names settled');
        return;
      }
    });

    return success;
  }*/

  Future<String> getKey(Presence presence) async {
    String k = '';

    if (await exists(presence) != presenceExists) {
      return '';
    }
    Map data = await getData();

    data.forEach((node, children) {
      if ((children['employee']['email'] as Employee).equals(presence.getEmployee()) &&
          (children['day'] as Day).equals(presence.getDay())) {
        //log.d('Okay we can get the key');

        k = node;
        return;
      }
    });
    return k;
  }

  dynamic getData() async {
    DatabaseEvent event = (await _ref.orderByChild(pre).once());
    var snapshot = event.snapshot;
    if (snapshot.value == null) return false;

    try {
      return snapshot.value as Map;
    } catch (e) {
      log.e('An error occurred: $e');
      return false;
    }
  }
Future<void> x(Employee employee) async {
    var data =await getData() as Map;
    data.forEach((key, value) {
      if(value['employee']['email']==employee.getEmail()) {
        _ref.child(key).remove();
      }
    });

}
  void clear() {
    _ref.remove();
    //log.d('All presence infos removed');
  }
/// Returns the final status of an employee the given day*
  Future<EStatus> getDailyFinalStatus(Employee employee, Day day) async {

    await DayManager().create(day);

    if (day.getStatus() == DStatus.holiday) return EStatus.inHoliday;
    if (day.getStatus() == DStatus.weekend) return EStatus.inWeekend;
    String status = 'inHolidays';
    var presences = await getData() as Map;
    presences.forEach((key, values) {
      if (employee.getEmail() == values['employee']['email'] &&
          day.getDate() == values['day']) {
        status = values['status'];
        return;
      }
    });
    return utils.convertES(status);
  }

  Future<Map<DateTime, EStatus>> getMonthReport(
      Employee employee, Day day) async {
        Day today = Day.today();
    int currentYear = today.getYear();
    int currentMonth = today.getMonth();
    EStatus status;
    int last =
        today.equals(day) ? today.getDayOfMonth() : day.getLengthOfMonth();
    Day d;
    Map<DateTime, EStatus> report = {};

    for (int i = 1; i <= last; i++) {
      d = Day.day(currentYear, currentMonth, i);
      status = await getDailyFinalStatus(employee, d);
      report[(DateTime(currentYear, currentMonth, i))] = status;
    }
    return report;
  }



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
     report.add(await getDailyReportCounts(service, d));

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
      //log.i(report[service]);
     // log.e("**********");
      //log.d(report);
    }

    return report;
  }

  Future<int> updateEntryTime(Presence presence, String entryTime) async {
    int val = await exists(presence);

    if (val != presenceExists) {
      //log.e("That presence doesnt exist and then canot be modified");

      return val;
    }

    if (!utils.checkFormat(entryTime)) {
      //log.e('Invalid entry time');

      return invalidEmail;
    }

    _ref.child(await getKey(presence)).update({'entry_time': entryTime});

    //log.d('Entry time updated successfully');

    return success;
  }

  Future<List<double>> count(Employee employee, Day day) async {
    int late = 0, absent = 0, present = 0;

    var data = await getMonthReport(employee, day);

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
  }

  Future<int> updateExitTime(Presence presence, String exitTime) async {
    int val = await exists(presence);

    if (val != presenceExists) {
      log.e("That presence doesn't exist and then cannot be modified");

      return val;
    }

    if (!utils.checkFormat(exitTime)) {
      log.e('Invalid exit time');

      return invalidEmail;
    }

    _ref.child(await getKey(presence)).update({'exit_time': exitTime});

    //log.d('Exit time updated successfully');

    return success;
  }

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

  Future<int> updateStatus(Presence presence, EStatus status) async {
    int val = await exists(presence);

    if (val != presenceExists) {
     // log.e('That presence doesnt exist and then cannot be modified');

      return val;
    }

    _ref.child(await getKey(presence)).update({'status': status});

    //log.d('Entry time updated successfully');

    return success;
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

  Future<void> generatePresences(String email) async {
    Day day;

    List<EStatus> employeeStatuses = [

      EStatus.present,
      EStatus.present,
      EStatus.absent,
      EStatus.absent,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend,

      EStatus.present,
      EStatus.present,
      EStatus.absent,
      EStatus.absent,
      EStatus.absent,

      EStatus.inWeekend,
      EStatus.inWeekend,

      EStatus.present,
      EStatus.present,
      EStatus.absent,
      EStatus.absent,
      EStatus.absent,

      EStatus.inWeekend,
      EStatus.inWeekend,



      EStatus.present,
      EStatus.late,
     /* EStatus.late,
      EStatus.absent,
      EStatus.present,

      EStatus.inWeekend,
      EStatus.inWeekend,*/
    ];

    Employee employee = Employee.target(email);
    await EmployeeManager().fetch(employee);
    Presence presence;

    for (int i = 1; i <= 23; i++) {

      day = Day.day(2023, 5, i);
      await DayManager().create(day);
      presence = Presence(day, employee);
      presence.setStatus(employeeStatuses[i - 1]);
       await PresenceManager().create(presence);

    }
  }

  Future<void> test() async {
    //generatePresences('andrew@gmail.com');
    //testMonthReport('andrew@gmail.com');
    //testCount();
 //tests('Direction');
 //tests('Secrétariat administratif');
   // tests('Comptabilité');
    //tests('Service scolarité');
    //tests('Service de coopération');

   //test2('Direction');
   //test2('Service scolarité');
   //test2('Service de coopération');
    //test2('Secrétariat administratif');
    //testAll();
    x(Employee.target('koko@gmail.com'));
  }

  Future<void> test2(String service) async {

    log.d('The start point');
    var x=await getMonthReportForAService(Service(service), Day.today());

    log.i('In this month for the $service service there are :');
    log.i('${x[0]}% of presence(s)');
    log.i('${x[1]}% of late(s)');
    log.i('${x[2]}% of absences(s)');
    log.i('${x[0]+x[1]+x[2]}% as sum of percentages');


  }

  Future<void> testMonthReport(String email) async {
    Employee employee = Employee.target(email);
    var report = await getMonthReport(employee, Day.today());
    log.i('report:$report');

    report.forEach((key, value) {
      log.i('date:$key status:$value');
    });
  }

  Future<void> tests(String service) async {
    var x=await getDailyReportCounts(Service(service), Day.today());
    log.d('Test****');
    log.i('The 2023-05-23, in the $service service there are :');
    log.i('${x[0]} presence(s)');
    log.i('${x[1]} late(s)');
    log.i('${x[2]} absences(s)');
  }

  Future<void> testCount() async {
    var data=await count(Employee.target('ezechieladede@gmail.com'), Day.today());
double sum=0;
    for(var item in data) {
      sum+=item;
      log.i(item);
    }

    log.i('Sum of percentages:$sum');
  }
}
