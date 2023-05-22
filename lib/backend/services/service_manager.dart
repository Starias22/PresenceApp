import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/utils.dart';

import '../models/service.dart';

class ServiceManager {
  late DatabaseReference _ref;
  final serv = "service";

  ServiceManager() {
    _ref = FirebaseDatabase.instance.ref('${serv}s');
  }

  Future<int> getCount() async {
    var data = await getData();
    log.i('data:$data');
    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, serv);
  }

  Future<int> create(Service service) async {
    dynamic val = service.isValid();
    if (!val) {
      log.e('Invalid service name');
      return invalidServiceName;
    }
    val = await exists(service);

    if (val == serviceExists) {
      log.e('That service already exists');
      return val as int;
    }

    int num = await getNextNum();
    _ref.child('$serv$num').set(service.toMap());
    log.d('Service creation successful');
    return success;
  }

  Future<int> exists(Service service) async {
    if (!service.isValid()) {
      log.e('Invalid service name');
      return invalidServiceName;
    }
    int test = serviceNotExists;
    var data = await getData();
    log.i(data);

    if (data != false) {
      (data as Map).forEach((node, childs) {
        if (childs['name'] == service.getName()) {
          log.d('The service exists');
          test = serviceExists;
          return;
        }
      });
    }
    return test;
  }

  Future<String> getKey(Service service) async {
    String k = '';

    if (await exists(service) != serviceExists) {
      return '';
    }
    Map data = await getData();

    data.forEach((key, chields) {
      if (chields['name'] == service.getName()) {
        k = key;

        log.d('Okay we can get the key');
        return;
      }
    });
    return k;
  }

  dynamic getData() async {
    DatabaseEvent event = (await _ref.orderByChild(serv).once());
    var snapshot = event.snapshot;
        if (snapshot.value == null) return false;

    try {
      log.i(snapshot.value as Map);
      return snapshot.value  as Map;
    } catch (e) {
      log.e('An error occured: $e');
      return false;
    }
  }

  void clear() {
    _ref.remove();
    log.d('All removed');
  }

  Future<int> delete(Service service) async {
    if (await exists(service) != serviceExists) {
      log.e('That service doesnt exist and then cannot be deleted'); 
      return serviceNotExists;
    }
    _ref.child(await getKey(service)).remove();
        log.e('Service removed successsfully');

    return success;
    

  }

  Future<int> update(Service service, String newName) async {
    if (!service.isValid()) {
      log.e('Invalid service name');
      return invalidServiceName;
    }
    if (!Service(newName).isValid()) {
      log.e('Invalid service name');
      return invalidServiceName;
    }

    if (service.equals(Service(newName))) {
      log.i('Same service name provided');
      return sameService;
    }

    int val = await exists(service);

    if (val != serviceExists) {
      log.e('The service you wanna change doesnt exists');

      return val;
    }
    val = await exists(Service(newName));
    if (val != serviceNotExists) {
      log.e('That new service name already exists');

      return newServiceExists;
    }

    _ref.child(await getKey(service)).update({'name': newName});
    service.setName(newName);
    return success;
  }


Future<void> test() async {
  log.d('Service testing');
  ServiceManager sm = ServiceManager();
  sm.clear();

  Service service = Service('');
  await sm.create(service); //invalid
  service.setName('Direction');

  await sm.create(service); //ok created
  await sm.create(service); //already exists
  service.setName('Secrétariat');
  await sm.create(service); //ok created
  await sm.getData();
  service.logInformations();

  await sm.update(service, ''); //update successful
  service.setName('Direction');
  await sm.update(service, 'Direction'); //same service name provided

  await sm.update(service, 'Direction modifiée'); //upd success

  service.setName('');
  await sm.delete(service); //invalid service name

  service.setName('not exists');
  await sm.delete(service); //not exists

  service.setName('last');
  await sm.create(service); //ok created

  await sm.getData();

  await sm.delete(service); //delete successful
  await sm.getData();
}

}
