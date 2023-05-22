import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/day_manager.dart';
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
    log.i('data: $data');

    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, pre);
  }

  Future<int> create(Presence presence) async {
    log.i('val:${presence.isValid()}');

    if (!presence.isValid()) {
      log.e('Invalid presence');

      return invalidPresence;
    }

    if (await exists(presence) == presenceExists) {
      log.e('That presence is already created');
      return presenceExists;
    }
    _ref.child('$pre${await getNextNum()}').set(presence.toMap());
    log.d('presence created successfully');

    return success;
  }

  Future<int> exists(Presence presence) async {
    if (!presence.isValid()) {
      return invalidPresence;
    }
    int test = presenceNotExists;
    var data = await getData();

    log.i(data);

    if (data != false) {
      (data as Map).forEach((node, childs) {
        if (Employee.target(childs['employee'])
                .equals(presence.getEmployee()) &&
            (Day(childs['day'])).equals(presence.getDay())) {
          test = presenceExists;
          log.d('Ok that presence tree exists');

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

    data.forEach((key, childs) {
      if ((childs['employee'] as Employee).equals(presence.getEmployee()) &&
          (childs['day'] as Day).equals(presence.getDay())) {
        log.d('Okay we can get the key');

        k = key;
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
      log.e('An error occured: $e');
      return false;
    }
  }

  void clear() {
    _ref.remove();
    log.d('All presence infos removed');
  }

  Future<EStatus> getFinalStatus(Employee employee, Day day) async {
    String status = 'inHolidays';

    await DayManager().create(day);

    if (day.getStatus() == DStatus.holiday) return EStatus.inHoliday;
    if (day.getStatus() == DStatus.weekend) return EStatus.inWeekend;

    var presences = await getData() as Map;
    presences.forEach((key, values) {
      if (employee.getEmail() == values['employee'] &&
          day.getDate() == values['day']) {
        status = values['status'];
        return;
      }
    });
    return utils.convertES(status);
  }

  Future<Map<DateTime, EStatus>> getMonthReport(
      Employee employee, Day day) async {


      log.d('Entry point////////////////////////////////');

    Day today = Day.today();
    int year = today.getYear();
    int month = today.getMonth();
    EStatus status;
    int last =
        today.equals(day) ? today.getDayOfMonth() : day.getLengthOfMonth();
    Day d;
    Map<DateTime, EStatus> report = {};

    log.d('////////////////////////////////');

    for (int i = 1; i <= last; i++) {
      d = Day.day(year, month, i);
      status = await getFinalStatus(employee, d);
      report[(DateTime(year, month, i))] = status;
    }
    return report;
  }

  Future<int> updateEntryTime(Presence presence, String entryTime) async {
    int val = await exists(presence);

    if (val != presenceExists) {
      log.e('That presence doesnt exist and then canot be modified');

      return val;
    }

    if (!utils.checkFormat(entryTime)) {
      log.e('Invalid entry time');

      return invalidEmail;
    }

    _ref.child(await getKey(presence)).update({'entry_time': entryTime});

    log.d('Entry time updated successsfully');

    return success;
  }

  Future<List<double>> count(Employee employee, Day day) async {
    int late = 0, absent = 0, present = 0;

    var data = await getMonthReport(employee, day);

    int length = data.length;

    data.forEach((date, status) {
      if (status == EStatus.present) {
        present++;
      } else if (status == EStatus.absent) {
        absent++;
      } else if (status == EStatus.late) {
        late++;
      }
    });
    return [present / length, absent / length, late / length];
  }

  Future<int> updateExitTime(Presence presence, String exitTime) async {
    int val = await exists(presence);

    if (val != presenceExists) {
      log.e('That presence doesnt exist and then canot be modified');

      return val;
    }

    if (!utils.checkFormat(exitTime)) {
      log.e('Invalid exit time');

      return invalidEmail;
    }

    _ref.child(await getKey(presence)).update({'exit_time': exitTime});

    log.d('Exit time updated successsfully');

    return success;
  }

  Future<int> updateStatus(Presence presence, EStatus status) async {
    int val = await exists(presence);

    if (val != presenceExists) {
      log.e('That presence doesnt exist and then canot be modified');

      return val;
    }

    _ref.child(await getKey(presence)).update({'status': status});

    log.d('Entry time updated successsfully');

    return success;
  }

  Future<void> generatePresences(String email) async {
    Day day;

    List<EStatus> employeeStatuses = [
      EStatus.present,
      EStatus.present,
      EStatus.absent,
      EStatus.late,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend,
      EStatus.present,
      EStatus.present,
      EStatus.present,
      EStatus.late,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend,
      EStatus.present,
      EStatus.late,
      EStatus.late,
      EStatus.absent,
      EStatus.present,
      EStatus.inWeekend,
    ];

    Employee employee = Employee.target(email);
    Presence presence;
    log.d('////////////////////////////');

    int x;
    for (int i = 1; i <= 21; i++) {
      log.d('round: $i');
      day = Day.day(2023, 5, i);
      await DayManager().create(day);
      presence = Presence(day, employee);
      presence.setStatus(employeeStatuses[i - 1]);
      x = await PresenceManager().create(presence);
      log.d('x:$x');
      log.d(('***********'));
    }
  }

  void test() {
    generatePresences('ezechieladede@gmail.com');
    testMonthReport('ezechieladede@gmail.com');
  }

  Future<void> testMonthReport(String email) async {
    Employee employee = Employee.target('bernard@gmail.com');
    var report = await getMonthReport(employee, Day.today());
    log.i('report:$report');

    report.forEach((key, value) {
      log.i('date:$key status:$value');
    });
  }
}
