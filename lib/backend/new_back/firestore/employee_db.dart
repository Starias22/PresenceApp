import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/new_back/firestore/holiday_db.dart';
import 'package:presence_app/backend/new_back/firestore/presence_db.dart';
import 'package:presence_app/backend/new_back/firestore/service_db.dart';
import 'package:presence_app/backend/new_back/models/employee.dart';
import 'package:presence_app/backend/new_back/models/presence.dart';

import '../../../utils.dart';


class EmployeeDB{


  final CollectionReference _employee =
  FirebaseFirestore.instance.collection('employees');

  Future<bool> create(Employee employee) async {

    if (await exists(employee.email)) return false;
    employee.serviceId=(await ServiceDB().getServiceIdByName(employee.service))!;
    DateTime now=DateTime.now();
    DateTime today=DateTime(now.year,now.month,now.day);
       await _employee.add(employee.toMap());
    employee.id=(await getEmployeeIdByEmail(employee.email))!;

    if(employee.status==EStatus.absent) {

      PresenceDB().create(Presence(date: today, employeeId: employee.id, status: EStatus.absent));
    }
    return true;
  }

  Future<bool> exists(String email) async {
    QuerySnapshot querySnapshot =
    await _employee.where('email', isEqualTo: email).limit(1).get();
        return querySnapshot.docs.isNotEmpty;
  }

  Future<List<Employee>> getEmployees(String serviceId) async {
   List<Employee> employees=
   (await getAllEmployees()).where((employee) => employee.serviceId==serviceId).toList();
  return employees;

}

  Future<String?> getEmployeeIdByEmail(String email) async {
    QuerySnapshot querySnapshot = await _employee
        .where('email', isEqualTo: email)
        .limit(1)
        .get();


    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<Employee> getEmployeeById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _employee.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;
  log.d('Checking');
    if (snapshot.exists) {


      // Convert the document snapshot into an Admin object
      Employee employee = Employee.fromMap(snapshot.data()!);
      log.i('Yeah exists');
      employee.id = snapshot.id;
      return employee;
    } else {
      throw Exception('Employee not found');
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    QuerySnapshot querySnapshot = await _employee.get();

    List<Employee> employees = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Employee.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return employees;
  }


  Future<void> delete(String id) async {

    await PresenceDB().removeAllPresenceDocuments(id);
    await HolidayDB().removeAllHolidayDocuments(id);
    _employee.doc(id).delete();
  }
  void updateCurrentStatus(String id,EStatus status){
    _employee.doc(id).update({'status':utils.str(status)});

  }


  Future<void> update(Employee employee) async {
   employee.serviceId=(await  ServiceDB().getServiceIdByName
     (employee.service))!;
    _employee.doc(employee.id).update(employee.toMap());
  }


}