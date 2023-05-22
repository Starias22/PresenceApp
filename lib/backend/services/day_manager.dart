import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/backend/models/employe.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/presence.dart';
import 'package:presence_app/backend/services/presence_manager.dart';
import 'package:presence_app/utils.dart';

import '../models/day.dart';

class DayManager {
  late DatabaseReference _ref;
  final day = "day";

  DayManager() {
    _ref = FirebaseDatabase.instance.ref('${day}s');
  }

  Future<int> getCount() async {
    var data = await getData();
    log.i('data: $data');

    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, day);
  }

  Future<int> create(Day day) async {
    dynamic val = day.isValid();
    if (!val) {
      log.e('Invalid day');
      return invalidDate;
    }
    int vl = await exists(day);
    if (vl == dayExists) {
      log.e('That day already exists');

      return vl;
    }

    log.d('Can be created*****');
    int num = await getNextNum();
    log.i(day.getStatus());
    _ref.child('${this.day}$num').set(day.toMap());
    log.d('Day created successfully');

    return success;
  }

  Future<int> exists(Day day) async {
    if (!day.isValid()) {
      log.e('Invalid day');

      return invalidDate;
    }
    int test = dayNotExists;
    var data = await getData();
    log.d('A test');

    log.i(data);

    if (data != false) {
      (data as Map).forEach((node, childs) {
        if (childs['date'] == day.getDate()) {
          log.d('***Of course');
          day.setStatus(utils.convert(childs['status']));
          test = dayExists;
          log.d('Ok the day exists');

          return;
        }
      });
    }
    return test;
  }

  Future<String> getKey(Day day) async {
    String k = '';

    if (await exists(day) != dayExists) {
      return '';
    }
    Map data = await getData();

    data.forEach((key, chields) {
      if (chields['date'] == day.getDate()) {
        log.d('Okay we can get the key');

        k = key;
        log.i('key:$key');

        return;
      }
    });
    return k;
  }

  dynamic getData() async {
    DatabaseEvent event = (await _ref.orderByChild(day).once());
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
  }

  Future<int> delete(Day day) async {
    if (await exists(day) != dayExists) {
      log.e('That day doesnt exist and then cannot be deleted');

      return dayNotExists;
    }
    _ref.child(await getKey(day)).remove();
    return success;
  }

  ///update the status of a day
  Future<int> update(Day day, DStatus status) async {
    if (!day.isValid()) {
      log.e('Invalid date');
      return invalidDate;
    }

    if (day.getStatus() == status) {
      log.i('Same status provided');
      return sameDStatus;
    }

    int val = await exists(day);

    if (val != dayExists) {
      log.e('That day doesnt exist and then canot be modified');

      return val;
    }

    _ref.child(await getKey(day)).update({'status': utils.str(status)});
    day.setStatus(status);
    return success;
  }

  Future<void> test() async {
    /*log.d('Day testing');
    DayManager dm = DayManager();
    dm.clear(); //all removed
    Day day = Day.today();

    //await getData();

    await dm.create(day); //success 1
    await dm.create(day); //alrady exists

    day.setDate('2023-01-15');
    await dm.create(day); //success 2

    await dm.delete(day); //deleted successf
    await dm.delete(day); //not exists

    day = Day.today();
    await dm.update(day, DStatus.holiday);

    await getData();*/

   
  }
}
