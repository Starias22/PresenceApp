import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/new_back/firestore/employee_db.dart';
import 'package:presence_app/backend/new_back/firestore/holiday_db.dart';
import 'package:presence_app/backend/new_back/models/employee.dart';
import 'package:presence_app/backend/new_back/models/presence.dart';


import '../../../utils.dart';

class PresenceDB {
  final CollectionReference _presence =
  FirebaseFirestore.instance.collection('presences');
  final CollectionReference _lastUpdate=
  FirebaseFirestore.instance.collection('last_update');





  void begin(){

    _lastUpdate.add({'date':utils.formatDateTime(DateTime.now())});

  }
  Future<bool> create(Presence presence) async {
    if (await exists(presence.date,presence.employeeId)) return false;
    _presence.add(presence.toMap());
    return true;
  }

  Future<bool> exists(DateTime dateTime, String employeeId) async {
    String date=utils.formatDateTime(dateTime);
    QuerySnapshot querySnapshot = await _presence
        .where('date', isEqualTo: date)
        .where('employee_id', isEqualTo: employeeId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }


  Future<String?> getPresenceId(DateTime dateTime,String employeeId) async {
    String date=utils.formatDateTime(dateTime);
    QuerySnapshot querySnapshot = await _presence
        .where('date', isEqualTo: date)
        .where('employee_id', isEqualTo: employeeId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<Presence> getPresenceById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _presence.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;

    if (snapshot.exists) {
      // Convert the document snapshot into a Presence object
      Presence presence = Presence.fromMap(snapshot.data()!);
      presence.id = snapshot.id;
      return presence;
    } else {
      throw Exception('Presence not found');
    }
  }
Future<void> removeAllPresenceDocuments(String employeeId) async {


  final querySnapshot = await _presence
      .where('employee_id', isEqualTo: employeeId)
      .get();

  final documentsToDelete = querySnapshot.docs;

  final batch = FirebaseFirestore.instance.batch();

  for (final doc in documentsToDelete) {
    batch.delete(doc.reference);
  }

  await batch.commit();

}

Future<List<String>> getPresenceIds(String employeeId) async {
  QuerySnapshot querySnapshot = await _presence
      .where('employee_id',isEqualTo: employeeId).get();
  List<String> presenceIds=[];
  List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
    return Presence.fromMap(doc.data() as Map<String,dynamic>);
  }).toList();

  for(var doc in presences){
    presenceIds.add(doc.id);
  }
  return presenceIds;
}

  Future<List<Presence>> getMonthPresenceRecords(String employeeId,DateTime date) async {
    DateTime now=DateTime.now();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);

    log.d('date asked: $date');
    log.d('today: $today');
    if(!date.isAtSameMomentAs(today)) {
      log.d('Not this month');
      date=DateTime(date.year,date.month,utils.lengthOfMonth(date));
    }
    String start=utils.formatDateTime(DateTime(date.year,date.month,1));
    String end=utils.formatDateTime(date);
    QuerySnapshot querySnapshot = await _presence
    .where('employee_id',isEqualTo: employeeId)
    .where('date', isGreaterThanOrEqualTo:start )
    .where('date',isLessThanOrEqualTo: end)
    .orderBy('date')
        .get()
    ;


    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;
  }

  Future<List<Presence>> getAllMonthPresenceRecords(DateTime date) async {
    DateTime now=DateTime.now();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);
    if(!date.isAtSameMomentAs(today)) {
      date=DateTime(date.year,date.month,utils.lengthOfMonth(date));
    }
    String start=utils.formatDateTime(DateTime(date.year,date.month,1));
    String end=utils.formatDateTime(date);
    QuerySnapshot querySnapshot = await _presence
        .where('date', isGreaterThanOrEqualTo:start )
        .where('date',isLessThanOrEqualTo: end).get();


    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;
  }

  void delete(String id) {
    _presence.doc(id).delete();




  }


  void update(Presence presence) {
    _presence.doc(presence.id).update(presence.toMap());
  }
  void updateEntryTime(String id,DateTime dateTime){
    String entryTime=utils.formatTime(dateTime);
    _presence.doc(id).update({'entry_time':entryTime});
  }
  void updateExitTime(String id,DateTime dateTime){
    String exitTime=utils.formatTime(dateTime);
    _presence.doc(id).update({'exit_time':exitTime});
  }
  void updateStatus(String id,EStatus status){

    _presence.doc(id).update({'status':utils.str(status)});
  }
  Future<void> setAttendance(String employeeId,DateTime date) async {
    EStatus status;
    if(utils.isWeekend(date)) {
      status=EStatus.inWeekend;
    }
    else if(await HolidayDB().isInHoliday(employeeId, date)) {
      status=EStatus.inHoliday;
    }
    else{
      status=EStatus.absent;
    }
    Presence presence=Presence(date: date, employeeId: employeeId, status: status);

    await create(presence);

    DateTime now=DateTime.now();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);
    if(date.isAtSameMomentAs(today)){
      EmployeeDB().updateCurrentStatus(employeeId, status);
    }
  }
  Future<void> setAllEmployeesAttendances(DateTime date) async {
    var employees = await EmployeeDB().getAllEmployees();
    for (var employee in employees) {
      setAttendance(employee.id, date);
    }
  }
    Future<void> setAllEmployeesAttendancesUntilCurrentDay() async {
       var lastUpdateDate=utils.format((_lastUpdate.limit(1).get() as
       Map<String,dynamic>)['date']);
       DateTime  date=lastUpdateDate!;
       DateTime now=DateTime.now();
       DateTime today=DateTime(now.year,now.month,now.day);
       date=DateTime(date.year,date.month,date.day);
       while(!date.isAtSameMomentAs(today)){
         setAllEmployeesAttendances(date);
         date=date.add(const Duration(days: 1));
       }

       String lastUpdateId=( await _lastUpdate.limit(1).get()).docs.first.id;
       _lastUpdate.doc(lastUpdateId).update({'date':utils.formatDateTime(today)});

    }





  Future<Map<DateTime, EStatus>> getMonthReport(String employeeId, DateTime date) async {

  List<Presence> presenceDocuments= await getMonthPresenceRecords(employeeId, date);

   Map<DateTime, EStatus> report = {};
   for(Presence presence in presenceDocuments){
     report[presence.date]=presence.status;
   }
    return report;
  }

  Future<void> test() async {
    generatePresences('ezechieladede@gmail.com');
  }

  Future<void> generatePresences(String email) async {
    String? employeeId = await EmployeeDB().getEmployeeIdByEmail(email);

    DateTime date = DateTime(2023, 5, 1);
    EStatus status = EStatus.present;
    Presence presence = Presence(
        date: date, employeeId: employeeId!, status: status);
    //await  create(presence);
   /* List<EStatus> statuses=[
      EStatus.present,
      EStatus.absent,
      EStatus.late,
      EStatus.late,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend ,

      EStatus.present,
      EStatus.present,
      EStatus.late,
      EStatus.present,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend ,

      EStatus.present,
      EStatus.present,
      EStatus.late,
      EStatus.present,
      EStatus.present,
      EStatus.inWeekend,
      EStatus.inWeekend ,

      EStatus.present,
      EStatus.absent,
      EStatus.late,
      EStatus.absent,
      EStatus.absent,
      EStatus.inWeekend ,

    ];
    for(var i=1;i<=27;i++){
      date=DateTime(2023,5,i);
      status=statuses[i-1];
      presence=Presence(date: date, employeeId: employeeId, status: status);
      create(presence);
      */

   List<EStatus> statuses = [

      EStatus.inWeekend,
      EStatus.inWeekend,

      EStatus.present,
      EStatus.absent,
      EStatus.late,
      EStatus.late,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend,



      EStatus.present,
      EStatus.present,
      EStatus.late,
      EStatus.present,
      EStatus.present,
      EStatus.inWeekend,
      EStatus.inWeekend,

      EStatus.present,
      EStatus.present,
      EStatus.late,
      EStatus.present,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend,

      EStatus.present,
      EStatus.absent,
      EStatus.late,
      EStatus.absent,
      EStatus.absent,
      EStatus.inWeekend,
      EStatus.inWeekend,

    ];
    for (var i = 1; i <= 30; i++) {
      date = DateTime(2023, 4, i);
      status = statuses[i - 1];
      presence = Presence(date: date, employeeId: employeeId, status: status);
      create(presence);
  }


}}
