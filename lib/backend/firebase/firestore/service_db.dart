import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/service.dart';
import 'package:presence_app/utils.dart';


class ServiceDB {
  final CollectionReference _service =
  FirebaseFirestore.instance.collection('services');

  Future<bool> create(Service service) async {
    if (await exists(service.name)) return false;
    _service.add(service.toMap());
   service.id=(await getServiceIdByName(service.name))!;
    _service.doc(service.id).update({'id':service.id});
    return true;
  }

  Future<bool> exists(String name) async {
    QuerySnapshot querySnapshot =
    await _service.where('name', isEqualTo: name).limit(1).get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<String?> getServiceIdByName(String name) async {
    QuerySnapshot querySnapshot = await _service
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<bool> hasEmployee(String serviceId) async {
    return (await EmployeeDB().getEmployees(serviceId)).isNotEmpty;
  }
  Future<Service> getServiceById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _service.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;

    if (snapshot.exists) {
      // Convert the document snapshot into an Admin object
     Service service = Service.fromMap(snapshot.data()!);
      service.id = snapshot.id;
      return service;
    } else {
      throw Exception('Service not found');
    }
  }


  Future<List<Service>> getAllServices() async {
    QuerySnapshot querySnapshot = await _service.orderBy('name').get();

    List<Service> services = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Service.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return services;
  }
  Future<List<String>> getServicesNames() async {
        List<Service> services = await getAllServices();
    List<String> names=[];

    for(var service in services) {
      names.add(service.name);
    }
    return names;
  }


  Future<bool> delete(String id) async {
    if(await hasEmployee(id)) return false;
    _service.doc(id).delete();
    return true;
  }


  Future<bool> update(Service old,Service service) async {
    if(await exists(service.name)) return false;
    service.id=(await getServiceIdByName(old.name))!;
    _service.doc(service.id).update(service.toMap());
 if(!await ServiceDB().hasEmployee(service.id)) {
   return true;
 }
    log.d('////////////////');
    List<Employee> employees=
    (await EmployeeDB().getAllEmployees()).
    where((employee) => employee.serviceId==service.id).toList();

    for(var employee in employees){

     await EmployeeDB().updateService(employee,service);
    }
    return true;
  }

}
