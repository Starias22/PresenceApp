import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';

import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/service.dart';
import 'package:presence_app/utils.dart';



class EmployeeDB{


  final CollectionReference _employee =
  FirebaseFirestore.instance.collection('employees');

  Future<bool> create(Employee employee) async {

    if (await exists(employee.email)) return false;
    employee.serviceId=(await ServiceDB().getServiceIdByName(employee.service))!;
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);

    if(employee.startDate.isAtSameMomentAs(today)) employee.status=EStatus.absent;

       await _employee.add(employee.toMap());
    employee.id=(await getEmployeeIdByEmail(employee.email))!;

    _employee.doc(employee.id).update({'id':employee.id});
    PresenceDB().setAttendance(employee.id, today);


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



  Future<bool> uniqueCodeExists(int uniqueCode) async {
    QuerySnapshot querySnapshot = await _employee
        .where('unique_code', isEqualTo: uniqueCode)
        .limit(1)
        .get();

   return querySnapshot.docs.isNotEmpty;



  }

  Future<String?> getEmployeeIdByFingerprintId(int fingerprintId) async {
    QuerySnapshot querySnapshot = await _employee
        .where('fingerprint_id', isEqualTo: fingerprintId)
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
    if (snapshot.exists) {


      // Convert the document snapshot into an Admin object
      Employee employee = Employee.fromMap(snapshot.data()!);
      employee.id = snapshot.id;
      return employee;
    } else {

      throw Exception('Employee not found');
    }
  }

  Future<Employee> getEmployeeByEmail(String email) async {

    QuerySnapshot querySnapshot = await _employee
        .where('email', isEqualTo: email)
        .limit(1)
        .get();


    DocumentSnapshot<Map<String, dynamic>> snapshot =
    querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>;
    if (snapshot.exists) {

      Employee employee = Employee.fromMap(snapshot.data()!);
      return employee;
    } else {
      throw Exception('Employee not found');
    }
  }


  Future<Employee?> getEmployeeByFingerprintId(int fingerprintId) async {

    QuerySnapshot querySnapshot = await _employee
        .where('fingerprint_id', isEqualTo: fingerprintId)
        .limit(1)
        .get();


    DocumentSnapshot<Map<String, dynamic>> snapshot =
    querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>;
    if (snapshot.exists) {

      Employee employee = Employee.fromMap(snapshot.data()!);
      return employee;
    } else {
      //throw Exception('Employee not found');
      return null;
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

  Future<void> updatePictureDownloadUrl(String employeeId,String url) async {
    await _employee.doc(employeeId).update({'picture_download_url':url});

  }
  void updateFingerprintId(String id,int fingerprintId){
    _employee.doc(id).update({'fingerprint_id':fingerprintId});
  }


  Future<void> update(Employee employee) async {
   employee.serviceId=(await  ServiceDB().getServiceIdByName
     (employee.service))!;
    _employee.doc(employee.id).update(employee.toMap());
  }
  Future<void> updateService(Employee employee, Service service) async {
    employee.serviceId=(await  ServiceDB().getServiceIdByName
      (service.name))!;
    employee.id=(await getEmployeeIdByEmail(employee.email))!;

    _employee.doc(employee.id).update({'service':service.name,
      'service_id':employee.serviceId});
  }


}