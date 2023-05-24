import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/utils.dart';

import '../models/planning.dart';

class PlanningManager {
  late DatabaseReference _ref;
  final plan = "planning";

  PlanningManager() {
    _ref = FirebaseDatabase.instance.ref('${plan}s');
  }

  Future<int> getCount() async {
    var data = await getData();
    log.i('data: $data');
    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, plan);
  }

  Future<int> create(Planning planning) async {
    bool val = planning.isValid();
    //log.i('val:$val');
    if (!val) {
      log.e('Invalid planning');
      return invalidPlanning;
    }

    int vl = await exists(planning);

    if (vl == planningExists) {
      log.e('That planning already exists');
      return vl;
    }

    int num = await getNextNum();
    _ref.child('$plan$num').set(planning.toMap());
    log.d('Planning created successfully');
    return success;
  }

  Future<int> exists(Planning planning) async {
    if (!planning.isValid()) {
      log.e('Invalid planning');

      return invalidPlanning;
    }
    int test = planningNotExists;
    var data = await getData();

    log.i(data);

    if (data != false) {
      (data as Map).forEach((node, childs) {
        if (childs['entry_time'] == planning.getEntryTime() &&
            childs['exit_time'] == planning.getExitTime()) {
          test = planningExists;
         // log.d('Ok the planning exists');

          return;
        }
      });
    }
    return test;
  }

  Future<String> getKey(Planning planning) async {
    String k = '';

    if (await exists(planning) != planningExists) {
      return '';
    }
    Map data = await getData();

    data.forEach((key, chields) {
      if (chields['entry_time'] == planning.getEntryTime() &&
          chields['exit_time'] == planning.getExitTime()) {
        k = key;
        //log.d('Okay we can get the key');

        return;
      }
    });
    return k;
  }

  dynamic getData() async {
    DatabaseEvent event = (await _ref.orderByChild(plan).once());
    var snapshot = event.snapshot;
    if (snapshot.value == null) return false;

    try {
      log.i(snapshot.value as Map<String, dynamic>);

      return snapshot.value as Map;
    } catch (e) {
      log.e('An error occurred: $e');

      return false;
    }
  }

  void clear() {
    _ref.remove();
    log.d('All plannings removed');
  }

  Future<int> delete(Planning planning) async {
    if (await exists(planning) != planningExists) {
      log.e('That planning doesnt exist and then cannot be deleted');

      return planningNotExists;
    }
    _ref.child(await getKey(planning)).remove();
    log.d('Planning removed successfully');

    return success;
  }

  Future<int> update(Planning planning, Planning newPlan) async {
    if (!planning.isValid()) {
      log.e('Invalid planning');

      return invalidPlanning;
    }
    if (!newPlan.isValid()) {
      log.e('Invalid new planning');

      return invalidNewPlanning;
    }

    if (planning.equals(newPlan)) {
               log.i('Same planning provided');

      return samePlanning;
    }

    int val = await exists(planning);

    if (val != planningExists) {
          log.e('That planning doesnt exist and then cannot be modified');
      return val;
    }
    val = await exists(newPlan);
    if (val != planningNotExists) {
              log.e('The new planning provided already exists');

      return planningExists;
    }

    _ref.child(await getKey(planning)).update(newPlan.toMap());
         log.d('Planning updated successfully');

    return success;
  }

  void test() async {
    log.d('Planning testing');
    PlanningManager pm = PlanningManager();
    pm.clear(); //all removed
    Planning planning = Planning('08:00', '17:00');

    await getData();

    await pm.create(planning); //success 1

    planning = Planning('0:00', '17:00');
  await pm.create(planning); //invalid

  planning = Planning('08:22', '17:00');
  await pm.create(planning); //ok created 2

  await pm.getData();

 await pm.update(planning, Planning('09:15', '18:20')); //success
await pm.getCount(); //1
  await pm.getData();

  await pm.delete(Planning('09:15', '18:20')); //ok del
  await pm.getCount(); //1
  planning = Planning('10:00', '17:00');
  await pm.create(planning); //ok created
    await pm.getCount(); //2


  planning = Planning('10:00', '18:00');
  await pm.create(planning); //ok created
      await pm.getCount(); //3


  planning = Planning('10:00', '17:00');
  await pm.create(planning); //already exists

  await pm.getCount();//4
  }
}
