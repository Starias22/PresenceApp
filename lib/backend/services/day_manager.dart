import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
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
    //log.i('data: $data');

    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, day);
  }

  Future<int> create(Day day) async {

    if (! day.isValid()) {
      //log.e('Invalid day');
      return invalidDate;
    }
    int vl = await exists(day);
    if (vl == dayExists) {
      //log.e('That day already exists');

      return vl;
    }

    //log.d('Can be created*****');
    int num = await getNextNum();
    log.i(day.getStatus());
    _ref.child('${this.day}$num').set(day.toMap());
    //log.d('Day created successfully');

    return success;
  }

  Future<int> exists(Day day) async {
    if (!day.isValid()) {
      log.e('Invalid day');

      return invalidDate;
    }
    int test = dayNotExists;
    var data = await getData();
   // log.d('A test');

    //log.i(data);

    if (data != false) {
      (data as Map).forEach((node, children) {
        if (children['date'] == day.getDate()) {
          day.setStatus(utils.convert(children['status']));
          test = dayExists;
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

    data.forEach((key, children) {
      if (children['date'] == day.getDate()) {
        k = key;
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
      log.e('An error occurred: $e');
      return false;
    }
  }
  Future<int> getMonthWorkdaysCount(Day day) async {
    Day d;
    int count=0;
   var days= await getData() as Map;

   Day today=Day.today();
   if(!day.equals(today)) {

     log.d('Day is not today');
     day=Day.day(day.getYear(),day.getMonth(),day.getLengthOfMonth());
   }
   //else{ log.d('Day is today');}
   days.forEach((key, value)
   {
     d=Day(value['date']);
     if(day.getYear()==d.getYear()&&
         day.getMonth()==d.getMonth()&&
         d.getDayOfMonth()<= day.getDayOfMonth()
     ) {
       if (d.getStatus() == DStatus.workday) {
         count++;
       }
     }
   });
   return count;
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
      //log.i('Same status provided');
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
    var count=await getMonthWorkdaysCount(Day.today());
    log.i('There are $count workdays in the month');
    count=await getMonthWorkdaysCount(Day('2023-04-01'));
    log.i('There were $count workdays in the previous month(april)');



  }
}
