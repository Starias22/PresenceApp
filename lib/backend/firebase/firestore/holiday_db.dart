import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';
import 'package:presence_app/utils.dart';

import 'employee_db.dart';


class HolidayDB {

  final CollectionReference _holiday =
  FirebaseFirestore.instance.collection('holidays');

  Future<int> create(Holiday holiday) async {
    int code;

    if (await isEveryEmployeeInHoliday(holiday)) return 203;
    if (await isAlreadyCreated(holiday)) return 200;

    //check if can be appended

    if(await hasBeenAppended(holiday)){//update an existing holiday
      log.d('Can be appended');
      code=201;
      return code;
    }
    else if(holiday.employeesIds==null&&await exists(holiday)){
      log.d('to all employees');
      code=207;
      delete((await getHolidayId(holiday))!);
    }
     //create a new holiday

      log.d('create a new holiday');
      _holiday.add(holiday.toMap());
      holiday.id=(await getHolidayId(holiday))!;
      _holiday.doc(holiday.id).update({'id':holiday.id});
      //update all matching presence documents
      DateTime now=await utils.localTime();

      DateTime today=DateTime(now.year,now.month,now.day);

      if(today.isAtSameMomentAs(holiday.startDate)){
        List<Employee> employees=await EmployeeDB().getAllEmployees();

        if(holiday.employeesIds != null){
          employees=
              employees.where((element) =>
                  holiday.employeesIds!.contains(element.id)).toList();

        }
      if(!utils.isWeekend(today)) {
        resetAttendanceToHoliday(employees, today);
      }

      }
      code=202;




    return code;
  }

  Future<void> resetAttendanceToHoliday(List<Employee> employees,
      DateTime date) async {


    for (var employee in employees){
      String employeeId=employee.id;
      var presenceId=await PresenceDB().getPresenceId(date,employeeId);
      var presence=await PresenceDB().getPresenceById(presenceId!);
      presence.entryTime=null;
      presence.exitTime=null;
      presence.status=EStatus.inHoliday;
      PresenceDB().update(presence);
      EmployeeDB().updateCurrentStatus(employeeId, EStatus.inHoliday);
    }


  }
  bool listContainsAll(List<dynamic>? list, List<String>? items) {
    if (items == null && list == null) return true;
    if (items == null || list == null) return false;

    return items.every((element) => list.contains(element));
  }
  bool listContainsNone(List<dynamic>? list, List<String>? items) {
    if (items == null || list == null) return true;
    if (items.isEmpty) return true;
    if (list.isEmpty) return true;

    return !items.any((element) => list.contains(element));
  }
  bool listNotContainsAll(List<dynamic>? list, List<String>? items) {
    // if (items == null || list == null) return true;
    // if (items.isEmpty) return true;
    // if (list.isEmpty) return true;
    if (items == null && list == null) return true;
    if (items == null || list == null) return false;

    return !items.every((element) => list.contains(element));
  }



  Future<bool> hasBeenAppended(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate);
    String endDate=utils.formatDateTime(holiday.endDate);

    log.d('We are going: ${holiday.employeesIds}');
    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)


        .limit(1)
        .get();

    var matchingDocuments = querySnapshot.docs.where((doc)
    {
      var docEmployeesIds = doc['employees_ids'] ;
      return listNotContainsAll(
        docEmployeesIds, holiday.employeesIds);
    }).toList();

    if(matchingDocuments.isEmpty) return false;

    var existingEmployeesIds = matchingDocuments.map((DocumentSnapshot doc) {
      // Explicitly cast the data to Map<String, dynamic> first
      var data = doc.data() as Map<String, dynamic>;

      // Now you can create the 'Holiday' object
      return Holiday.fromMap(data);
    }).toList().first.employeesIds;



    for (var employeeId in (holiday.employeesIds ?? [])) {
      if (!existingEmployeesIds!.contains(employeeId)) {
        existingEmployeesIds.add(employeeId);
      }
    }

    _holiday.doc(querySnapshot.docs.first.id).
    update({'employees_ids':existingEmployeesIds,
            'last_update_date':await utils.localTime()});

    return true;
  }


  Future<bool> isEveryEmployeeInHoliday(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate);
    String endDate=utils.formatDateTime(holiday.endDate);

    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)
        .where('employees_ids',isNull:true )
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }





  Future<bool> isAlreadyCreated(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate);
    String endDate=utils.formatDateTime(holiday.endDate);

    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)
        .get();

      var matchingDocuments = querySnapshot.docs.where((doc)
      {
        var docEmployeesIds = doc['employees_ids'] ;
        return listContainsAll
          (docEmployeesIds, holiday.employeesIds);
      }).toList();


    return matchingDocuments.isNotEmpty;
  }


  Future<bool> exists(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate);
    String endDate=utils.formatDateTime(holiday.endDate);

    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }




  Future<String?> getHolidayId(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate),
        endDate=utils.formatDateTime(holiday.endDate);
    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)

        .get();
    // var matchingDocuments = querySnapshot.docs.where((doc)
    // {
    //   var docEmployeesIds =  doc['employees_ids'] ;
    //   return listContainsAll
    //     (docEmployeesIds, holiday.employeesIds);
    // }).toList();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<Holiday> getHolidayById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _holiday.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;

    if (snapshot.exists) {

      // Convert the document snapshot into an Holiday object
     Holiday holiday = Holiday.fromMap(snapshot.data()!);
      holiday.id = snapshot.id;
      return holiday;
    } else {
      throw Exception('Holiday not found');
    }
  }


  Future<List<Holiday>> getAllHolidays() async {
    QuerySnapshot querySnapshot = await _holiday.get();

    List<Holiday> admins = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Holiday.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return admins;
  }


  void delete(String id) {
    _holiday.doc(id).delete();

  }


  void update(Holiday holiday) {
    _holiday.doc(holiday.id).update(holiday.toMap());
  }
  void updateStartDate(String id,DateTime dateTime){
    String startDate=utils.formatDateTime(dateTime);
    _holiday.doc(id).update({'start_date':startDate});
  }
  void updateEndDate(String id,DateTime dateTime){
    String endDate=utils.formatDateTime(dateTime);
    _holiday.doc(id).update({'end_date':endDate});
  }
  Future<bool> isInHoliday(String employeeId,DateTime dateTime) async {
    if(await isHoliday(dateTime) ){
      return true;
    }
    String date=utils.formatDateTime(dateTime);
    QuerySnapshot querySnapshot = await _holiday
        .where('employees_ids', arrayContains: employeeId)
        .where('start_date', isLessThanOrEqualTo: date)
        .get();
    QuerySnapshot queryEnd = await _holiday
        .where('employee_id', isEqualTo: employeeId)
        .where('end_date', isGreaterThanOrEqualTo: date)
        .get();
    return querySnapshot.docs.isNotEmpty&&queryEnd.docs.isNotEmpty;
  }

  Future<bool> isHoliday(DateTime dateTime) async {
    String date=utils.formatDateTime(dateTime);
    QuerySnapshot querySnapshot = await _holiday
        .where('employees_ids',isEqualTo:null)
        .where('start_date', isLessThanOrEqualTo: date)
        .limit(1)
        .get();
    QuerySnapshot endQuerySnapshot = await _holiday
        .where('employee_id', isEqualTo: null)
        .where('end_date', isGreaterThanOrEqualTo: date)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty&& endQuerySnapshot.docs.isNotEmpty ;
  }


  Future<void> removeAllHolidayDocuments(String employeeId) async {
    final querySnapshot = await _holiday
        .where('employees_ids', arrayContains: employeeId)
        .get();
    final documentsToDelete = querySnapshot.docs;
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in documentsToDelete) {
      batch.delete(doc.reference);
    }
  }

  Future<List<String>> getHolidayIds(String employeeId) async {
    QuerySnapshot querySnapshot = await _holiday
        .where('employees_ids',arrayContains: employeeId).get();
    List<String> holidayIds=[];
    List<Holiday> holidays = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Holiday.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    for(var doc in holidays){
      holidayIds.add(doc.id);
    }
    return holidayIds;
  }


}
