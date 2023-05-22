import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/backend/models/admin.dart';

import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/admin_manager.dart';
import 'package:presence_app/backend/services/day_manager.dart';
import 'package:presence_app/backend/services/planning_manager.dart';
import 'package:presence_app/backend/services/service_manager.dart';
import 'package:presence_app/utils.dart';

import '../models/planning.dart';
import '../models/service.dart';
import 'login.dart';

class EmployeeManager {
  late DatabaseReference _ref;
  final emp = "employee";

  EmployeeManager() {
    _ref = FirebaseDatabase.instance.ref('${emp}s');
  }

  Future<int> getCount() async {
    var data = await getData();
    log.i('data: $data');

    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, emp);
  }

  Future<int> create(Employee employee) async {
    log.d('****Lets create ');

    int val = employee.isValid();
    log.i('val:$val');

    if (val != success) {
      log.e('Invalid employee');

      return val;
    }
    val = await exists(employee);
    if (val == emailExists) {
      log.e('That email is already assigned to an employee');
      return emailInUse;
    }

    if (await 
    AdminManager().exists(Admin.target(employee.getEmail())) ==
        emailExists) {
        log.e('That email is already assigned to an admin');

      return adminExists;
    }
    log.d('****Lets create ');

    PlanningManager().create(employee.getPlanning());
    ServiceManager().create(employee.getService());
    DayManager().create(employee.getAddDay());
    int num = await getNextNum();

    _ref.child('$emp$num').set(employee.toMap());
    log.d('Employee created successfully');
    

    return success;
  }

  Future<int> exists(Employee employee) async {
    log.d('check exists');
    if (!employee.hasValidEmail()) {
      log.e('invalid email');

      return invalidEmail;
    }
    int test = emailNotExists;
    var data = await getData();

    log.i(data);

    if (data != false) {
      (data as Map).forEach((node, childs) {
        if (childs['email'] == employee.getEmail()) {
          test = emailExists;
          log.d('Ok the employee exists');

          return;
        }
      });
    }
    return test;
  }

  Future<int> fetch(Employee employee) async {
    if (!employee.hasValidEmail()) {
      log.e('Invalid email');

      return invalidEmail;
    }

    var data = await getData();

    log.i('Not empty?$data');

    if (data == false) return emailNotExists;

    (data as Map).forEach((node, childs) {
      if (childs['email'] == employee.getEmail()) {
        employee.setFname(childs['firstname']);
        employee.setLname(childs['lastname']);
        //employee.setGender(childs['gender']);
        employee.setService(Service(childs['service']['name']));
        employee.setCurrentStatus(EStatus.absent);
        employee.setPlanning(Planning(
            childs['planning']['entry_time'], childs['planning']['exit_time']));

        return;
      }
    });

    return success;
  }

  Future<String> getKey(Employee employee) async {
    String k = '';

    if (await exists(employee) != emailExists) {
      return '';
    }
    Map data = await getData();

    data.forEach((key, chields) {
      if (chields['email'] == employee.getEmail()) {
        log.d('Okay we can get the key');

        k = key;
        return;
      }
    });
    return k;
  }

  dynamic getData() async {
    DatabaseEvent event = (await _ref.orderByChild(emp).once());
    var snapshot = event.snapshot;
    if (snapshot.value == null) return false;

    try {
      return snapshot.value as Map;
    } catch (e) {
      log.e('***An error occured: $e');
      return false;
    }
  }

  void clear() {
    _ref.remove();
    log.d('All admins removed');
  }

  Future<int> delete(Employee employee) async {
    if (await exists(employee) != emailExists) {
      log.e('Invalid email or no such employee');

      return emailNotExists;
    }
    _ref.child(await getKey(employee)).remove();
    log.e('Employee removed successsfully');

    return success;
  }

  Future<int> update(Employee employee, String newEmail) async {
    int val = await exists(employee);

    if (val != emailExists) {
      log.e('That employee doesnt exist and then canot be modified');

      return val;
    }

    if (!utils.isValidEmail(newEmail)) {
      log.e('Invalid email for that employee');

      return invalidEmail;
    }

    if (newEmail == employee.getEmail()) {
      log.i('Same email provided');

      return sameEmail;
    }

    val = await exists(Employee.target(newEmail));
    if (val != emailNotExists) {
      log.e('The new email provided is already in use');

      return emailInUse;
    }

    _ref.child(await getKey(employee)).update({'email': newEmail});
    employee.setEmail(newEmail);
    log.d('Admin email updated successsfully');

    return success;
  }

  Future<int> updateService(Employee employee, Service service) async {
    int val = await ServiceManager().create(service);

    if (val == invalidServiceName) {
      log.e('Invalid service name');
      return val;
    }

    val = await exists(employee);

    if (val != emailExists) {
      log.e('That employee doesnt exist and then canot be modified');

      return val;
    }
    await fetch(employee);

    if (service == employee.getService()) {
      log.i('Same service provided');

      return sameService;
    }
    _ref.child(await getKey(employee)).update({'service': service.toMap()});
    log.d('Employeee service updated successsfully');

    return success;
  }

  Future<int> updatePlanning(Employee employee, Planning planning) async {
    int val = await PlanningManager().create(planning);

    if (val == invalidPlanning) {
      log.e('Invalid service name');
      return val;
    }

    val = await exists(employee);

    if (val != emailExists) {
      log.e('That employee doesnt exist and then canot be modified');

      return val;
    }
    await fetch(employee);

    if (planning == employee.getPlanning()) {
      log.i('Same splanning provided');

      return samePlanning;
    }

    _ref.child(await getKey(employee)).update({'planning': planning.toMap()});
    log.d('Employeee planning updated successsfully');

    return success;
  }

  Future<int> updateStatus(Employee employee, EStatus status) async {
    int val = await exists(employee);

    if (val != emailExists) {
      log.e('That employee doesnt exist and then canot be modified');

      return val;
    }
    await fetch(employee);

    _ref.child(await getKey(employee)).update({'status': utils.str(status)});
    log.d('Employeee status updated successsfully');

    return success;
  }

  Future<int> enrollFingerprint(Employee employee, String fingerprint) async {
    int val = await exists(employee);

    if (val != emailExists) {
      log.e('That employee doesnt exist and then canot be modified');

      return val;
    }
    await fetch(employee);

    _ref.child(await getKey(employee)).update({'fingerprint': fingerprint});
    log.d('Employeee fingerprint enrolled successsfully');

    return success;
  }

  Future<int> updateEmail(String newEmail) async {
    return await Login().updateEmailForCurrentUser(newEmail);
  }

  Future<int> updatePassword(String newPassword) async {
    return await Login().updatePasswordForCurrentUser(newPassword);
  }

  Future<int> signIn() async {
    var val = await Login().googleSignIn();
    /*if (val == success && await exists(employee) == emailNotExists) {
     
    }*/

    return val;
  }

  Future<int> signOut() async {
    return await Login().googleSingOut();
  }

  Future<int> _deleteCurrentAccount() async {
    return await Login().deleteCurrentUser();
  }

  void test() async {
    Employee employee =
        Employee('adedeezechiel@gmail.com', 'Ezéchiel', 'ADEDE', 'gender');
    Service service = Service('Direction');
    Planning planning = Planning.defaultp();
    clear();
    employee.setService(service);
    employee.setPlanning(planning);

    await create(employee);
    service.setName('Secrétariat');
    planning.setEntryTime('09:15');

    employee.setEmail('ezechieladede@gmail.com');
    employee.setPlanning(planning);
    employee.setService(service);

    //await create(employee);
  }
}
