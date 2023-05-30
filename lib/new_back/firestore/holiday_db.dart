import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:presence_app/main.dart';

import '../models/holiday.dart';


class HolidayDB {
  final CollectionReference _holiday =
  FirebaseFirestore.instance.collection('holidays');

  Future<bool> create(Holiday holiday) async {
    if (await exists(holiday)) return false;
    _holiday.add(holiday.toMap());
    return true;
  }

  Future<bool> exists(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate);
    String endDate=utils.formatDateTime(holiday.endDate);

    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)
        .where('employee_id', isEqualTo: holiday.employeeId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }


  Future<String?> getHolidayId(Holiday holiday) async {
    String startDate=utils.formatDateTime(holiday.startDate),
        endDate=utils.formatDateTime(holiday.endDate);
    QuerySnapshot querySnapshot = await _holiday
        .where('start_date', isEqualTo: startDate)
        .where('end_date', isEqualTo: endDate)
        .where('employee_id', isEqualTo: holiday.employeeId)
        .limit(1)
        .get();

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
    String date=utils.formatDateTime(dateTime);
    QuerySnapshot querySnapshot = await _holiday
        .where('employee_id', whereIn: [null,employeeId])
        .where('start_date', isLessThanOrEqualTo: date)
        .where('end_date', isGreaterThanOrEqualTo: date)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> isHoliday(DateTime dateTime) async {
    String date=utils.formatDateTime(dateTime);
    QuerySnapshot querySnapshot = await _holiday
        .where('employee_id',isEqualTo:null)
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
        .where('employee_id', isEqualTo: employeeId)
        .get();
    final documentsToDelete = querySnapshot.docs;
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in documentsToDelete) {
      batch.delete(doc.reference);
    }
  }

  Future<List<String>> getHolidayIds(String employeeId) async {
    QuerySnapshot querySnapshot = await _holiday
        .where('employee_id',isEqualTo: employeeId).get();
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
