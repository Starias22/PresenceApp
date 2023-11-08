import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/holiday_db.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/models/presence_report_model/presence_report.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/presence.dart';
import 'package:presence_app/utils.dart';

class PresenceDB {
  final CollectionReference _presence =
  FirebaseFirestore.instance.collection('presences');
  final CollectionReference _lastUpdate=
  FirebaseFirestore.instance.collection('last_update');
  late String currentPresenceId;
  late DateTime currentStartDate;





  Future<void> begin() async {

    _lastUpdate.add({'date':utils.formatDateTime(await utils.localTime())});


  }
  Future<bool> create(Presence presence) async {
    if (await exists(presence.date,presence.employeeId)) return false;

    _presence.add(presence.toMap());
    presence.id=(await getPresenceId(presence.date,presence.employeeId))!;

    _presence.doc(presence.id).update({'id':presence.id});
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

Future<bool> entered(String employeeId,DateTime dateTime) async {

  log.d("Ezechiel Bandit:......................... $employeeId");
  log.d("Date Time:......................... $dateTime");
  var x = await getPresenceId(dateTime, employeeId);
  log.d("Get Presence:......................... $x");
    return (await getPresenceById(x!))
        .entryTime!=null;

}
  Future<bool> exited(String employeeId,DateTime dateTime) async {
    return (await getPresenceById
      ((await getPresenceId(dateTime, employeeId))!)).exitTime!=null;
  }
  Future<int> handleEmployeeAction( Employee employee,DateTime dateTime) async {


    DateTime today=DateTime(dateTime.year,dateTime.month,dateTime.day);
    if(utils.isWeekend(today)) {
      return isWeekend;
    }
    if(employee.startDate.isAfter(today))
    {
      return notYet;
    }

    String? employeeId=employee.id;

   if(await HolidayDB().isInHoliday(employeeId, dateTime)) {
     return inHoliday;
   }

   if(await entered(employeeId,today)) {

     if(await exited(employeeId,today)){
       return exitAlreadyMarked;
     }
     return  markExit(employee,dateTime);

   }

     markEntry(employee,dateTime);
     return entryMarkedSuccessfully;

     }


  Future<String?> getPresenceId(DateTime dateTime,String employeeId) async {
    String date=utils.formatDateTime(dateTime);

    log.d("Affichage de date ::::::::::::::::::: $date");
    log.d("Affichage de l'id de emp ::::::::::::::::::: $employeeId");

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

  Future<void> remove() async {


    final querySnapshot = await _presence
        .where('date', isEqualTo: '2023-06-03')
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

  Future<List<Presence>> getAllDailyPresenceRecords
      ( {required DateTime date,
    List<String> status=const['present','late' ]
      }) async {

        QuerySnapshot querySnapshot = await _presence
            .where('date',isEqualTo: utils.formatDateTime(date))
            .where('status',whereIn: status)
            .orderBy('entry_time')
            .orderBy('exit_time')
            .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    log.d('The presences list: ${presences.length}') ;
    return presences;
  }



  Future<List<Presence>> getAllPresenceRecords
      () async {

    QuerySnapshot querySnapshot = await _presence
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();
    return presences;
  }


  Future<List<Presence>> getDailyPresenceRecords(
      {
    List<String> status=const['present','late' ],
   List<String>? services, required DateTime date,
    List<String>? employeesIds}
      )
  async {
    List<Presence> presences;

    if(services==null&&employeesIds==null)
    {
      log.d('Of course all');
      presences=await getAllDailyPresenceRecords(date: date,status: status);
      log.d('All daily presence record are got');
    }

    else
    {
      if(services!=null)
        {
          presences= await getSomeServicesDailyPresenceRecords
            (date: date, services: services,status: status );
        }
      else//employeesIds!=null
      {
        presences=await getSomeEmployeesDailyPresenceRecords
          (date: date, employeesIds: employeesIds!,status: status  );
      }
      
    }

    log.d('Returning presence documents') ;
    return presences;
  }
  //
  // Future<Map<String,List<Presence>>> groupPresenceRecordsByService
  //     ( List<Presence> presences) async {
  //
  //   List<Presence> presenceRecords=[] ;
  //   Map<String,List<Presence>> groupedReport={};
  //   var services=await ServiceDB().getAllServices();
  //   Employee employee;
  //
  //   for(var service in services){
  //
  //     presenceRecords=[] ;
  //     for(var presence in presences){
  //
  //     employee=(await EmployeeDB().getEmployeeById(presence.employeeId));
  //     if(employee.service==service.name){
  //       presenceRecords.add(presence);
  //
  //     }
  //     groupedReport[service.name]=presenceRecords;
  //     }
  //
  //   }
  //   return groupedReport;
  //
  // }

  Future<List<Presence>> getSomeEmployeesDailyPresenceRecords({ 
    required DateTime date,
     required List<String> employeesIds,
    List<String> status=const['present','late' ]}) async {

    QuerySnapshot querySnapshot = await _presence
        .where('date',isEqualTo: utils.formatDateTime(date))
        .where('employee_id',whereIn: employeesIds)
        .where('status',whereIn: status)
        .orderBy('entry_time')
        .orderBy('exit_time')
    
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;
  }


  Future<List<Presence>> getSomeEmployeesPeriodicPresenceRecords({
    required DateTime start,
    required DateTime end,
    required List<String> employeesIds,
    List<String> status=const['present','late' ]}) async {

    QuerySnapshot querySnapshot = await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .where('employee_id',whereIn: employeesIds)
        .where('status',whereIn: status)
        .orderBy('entry_time')
        .orderBy('entry_time')
        .orderBy('exit_time')

        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;
  }


  Future<List<Presence>> getSomeServicesDailyPresenceRecords({
    required DateTime date,
    required List<String> services,
    List<String> status=const['present','late' ]}) async {


    QuerySnapshot querySnapshot = await _presence
        .where('date',isEqualTo: utils.formatDateTime(date))
        .where('employee_service', whereIn: services )
        .orderBy('entry_time')
        .orderBy('exit_time')
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList().
    where((presence) =>status.contains(utils.str(presence.status)) ).toList();

    return presences;
  }


  Future<List<Presence>> getAServiceDailyPresenceRecords
      ({ required DateTime date,
     required String service,
    List<String> status=const['present','late' ]}) async {



    QuerySnapshot querySnapshot = await _presence
        .where('date',isEqualTo: utils.formatDateTime(date))
        .where('employee_service', isEqualTo:service )
        .where('status',whereIn: status)
        .orderBy('entry_time')
        .orderBy('exit_time')

        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;


  }
  


  Future< List<Presence>> getPresenceRecords(
      {required ReportType reportType, required DateTime start, DateTime?
      end,   List<String> status=const['present','late' ],
        List<String>? services,

        List<String>? employeesIds}) async {
    List<Presence> presences;


    if(reportType==ReportType.daily) {
      
      log.d('Daily presence records') ;
      presences=await getDailyPresenceRecords(
        employeesIds: employeesIds,
        services: services, date: start,status: status,);
      log.d('All daily presence records are got') ;
    }

    else if(reportType==ReportType.periodic) {
      log.d('Periodic presence records') ;
      presences=await getPeriodicPresenceReport(
        status: status,
        services: services,
        employeesIds: employeesIds,
          start: start,end: end!);
    }

    else //monthly or annually or weekly
        {

     var limits= await getLimits(reportType, start);
     presences=await getPeriodicPresenceReport(
       status: status,
         employeesIds: employeesIds,
         services: services,
         start: limits[0],
         end:limits[1]);
    }
    log.d('Returning all daily presence records');
    return presences;
  }


  Future<Map<String?, List<double>>> getPresenceStatistics(
      {required ReportType reportType, required DateTime start, DateTime?
  end,
    List<String> status=const['present','late','absent' ],
    required List<String>? services,

    List<String>? employeesIds,
    bool? groupByService
  })

  async {
    Map<String?, List<Presence> > presenceReport=
    await  getPresenceReport(
        reportType: reportType,
        start: start,
        services: services,
        end: end,
        status: status,
        employeesIds: employeesIds,
        groupByService: groupByService);
    int total,pre,late,abs;
    List<double> statistics=[];
    List<Presence> presences=[];

    Map<String?, List<double> >report={};
    for(var entry in presenceReport.entries){
      var service=entry.key;
      presences=presenceReport[service]!;
      total=presences.length;
      pre= presences.where((doc) =>doc.status==EStatus.present ).length;
      late= presences.where((doc) =>doc.status==EStatus.late ).length;
      abs= presences.where((doc) =>doc.status==EStatus.absent ).length;
      statistics=total==0?[0,0,0]:[100*pre/total,100*late/total,100*abs/total];
      report[service]=statistics;
    }

    return report;
  }



  Future<Map<String?, List<Presence>>> getPresenceReport(
      {required ReportType reportType, required DateTime start, DateTime?
      end,
        List<String> status=const['present','late' ],
        required List<String>? services,

        List<String>? employeesIds,
        bool? groupByService
      }
      ) async {




    Map<String?, List<Presence>> report={};

    log.d('Getting presence report');

    List<Presence> presences=await getPresenceRecords(
        reportType: reportType, start: start,
        end: end,status: status,
        services: services,employeesIds: employeesIds
    );
    log.d('Presence records are got');
    log.d('number: ${presences.length}');

    if(groupByService==null||!groupByService){

      log.d('Do not group by service');
      report[null]=presences;
      log.d('Okay doing');
    }

    else//groupByService is true
    {

    for(var service in services!) {

     report[service]= presences.where((presence) =>
     presence.employeeService==service ).toList();

    }

    }
    log.d('Report to be returned: $report');

    return report;
  }

  Future<List<Presence>> getSomeServicesPeriodicPresenceReport(
      {required DateTime start,required DateTime
      end,required List<String> services,
  List<String> status=const['present','late']}) async {


    QuerySnapshot querySnapshot = await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .where('employee_service', whereIn: services )
        .orderBy('date')
        .orderBy('entry_time')
        .orderBy('exit_time')
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList().
    where((presence) =>status.contains(utils.str(presence.status)) ).toList();

    return presences;

  }


  Future<List<Presence>> getAServicePeriodicPresenceRecords(
      {required DateTime start,required DateTime
      end,required String service,
        List<String> status=const['present','late' ],
      }) async {



    QuerySnapshot querySnapshot = await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .where('employee_service', isEqualTo:service )
        .where('status',whereIn: status)
        .orderBy('entry_time')
        .orderBy('exit_time')

        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;



  }


  Future<List<Presence>> getAnnualPresenceReport({required DateTime year,
    List<String> status=const['present','late' ],
    List<String>? servicesIds,
    List<String>? employeesIds
  }) async {
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);

    DateTime date=DateTime(year.year,year.month,year.day);

    if(!date.isAtSameMomentAs(today)) {

      date=DateTime(date.year,date.month,utils.lengthOfMonth(date));
    }

    DateTime start=DateTime(date.year,1,1);

    DateTime end=date;
    return await getPeriodicPresenceReport(start: start, end: end,status: status,
        employeesIds: employeesIds,services: servicesIds);


  }


  Future<List<DateTime>> getLimits(ReportType reportType,DateTime d
  )  async {
    DateTime start;
    DateTime end;
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);


    DateTime date=DateTime(d.year,d.month,d.day);
    end=DateTime(1970,1,1);

    if(date.isAtSameMomentAs(today)) {

      end=today;
    }


    if(reportType==ReportType.monthly){

  start=DateTime(d.year,d.month,1);
  log.d('The start is the following :$start');



      if(!date.isAtSameMomentAs(today)) {

        end=DateTime(date.year,date.month ,utils.lengthOfMonth(date));
        log.d('The end is the following :$end');
      }

    }



else if(reportType==ReportType.weekly)
{

  start=utils.getWeeksMonday(date);

  if(!date.isAtSameMomentAs(today)) {

    end=utils.getWeeksFriday(date);
  }



}

    else// if(reportType==ReportType.annual)
    {

      start=DateTime(d.year,DateTime.january,1);


      if(!date.isAtSameMomentAs(today)) {

        end=DateTime(date.year,DateTime.december ,31);
      }



    }
    return [start,end];








  }

  Future<List<Presence>> getMonthlyPresenceReport({required DateTime month,
    List<String> status=const['present','late' ],
    List<String>? servicesIds,
    List<String>? employeesIds
  }) async {
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);

   DateTime date=DateTime(month.year,month.month,month.day);

    if(!date.isAtSameMomentAs(today)) {

      date=DateTime(date.year,date.month,utils.lengthOfMonth(date));
    }
    DateTime start=DateTime(date.year,date.month,1);

    DateTime end=date;
    return await getPeriodicPresenceReport(start: start, end: end,status: status,
    employeesIds: employeesIds,services: servicesIds);


  }
  Future<List<Presence>> getAllPeriodicPresenceRecords(
      {required DateTime start,required DateTime end,
        List<String> status=const ['present','late']
      }) async {

    QuerySnapshot querySnapshot = await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .where('status',whereIn: status)
        .orderBy('date')
        .orderBy('entry_time')
        .orderBy('exit_time')
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return presences;
  }

  Future<Map<String, double>> getEntryStatisticsInRange(
      {required DateTime start,required DateTime end,
        required String employeeId,int num=4

      }) async {
    QuerySnapshot querySnapshot;
    querySnapshot= await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .where('employee_id',isEqualTo: employeeId)
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).where((presence) => presence.entryTime!=null).toList();
    if(presences.isEmpty) return {};
    presences.sort((first, second) =>
        first.entryTime!.compareTo(second.entryTime!));

    var limits=await getEntryTimeLimits(start, end);
    if(limits.isEmpty) return {};


    DateTime inf=limits[0];
    DateTime sup=limits[1];
    inf=utils.roundToPreviousHour(inf);
    sup=utils.roundToNextHour(sup);

    var entryIntervals=subdivideDateTimeInterval(inf, sup, num);
    int total=presences.length;
    Map< String,double> statistics={};


    for(var interval in entryIntervals){
      statistics[utils.getTimeRangesAsStr(interval)]=
          (presences.where((presence) =>
              presence.isEntryInRange(interval)).length*100.0/total).
          roundToDouble();
    }
    return statistics;
  }


  Future<List<DateTime>> getEntryTimeLimits(
       DateTime start, DateTime end,
         ) async {

    QuerySnapshot querySnapshot;
    querySnapshot= await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .get()
    ;

    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).where((presence) => presence.entryTime!=null).toList();

    if(presences.isEmpty) return [];
    presences.sort((a, b) =>
    a.entryTime!.isBefore(b.entryTime!) ? -1 : 1);

    DateTime? inf=presences.first.entryTime;
    log.d('The inf  $inf');
    DateTime? sup=presences.last.entryTime;
    log.d('The sup  $sup');
    return [inf!,sup!];
  }

  Future<List<DateTime>> getExitTimeLimits(
      DateTime start, DateTime end,
      ) async {

    QuerySnapshot querySnapshot;
    querySnapshot= await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .get()
    ;

    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).where((presence) => presence.exitTime!=null).toList();

    if(presences.isEmpty) return [];
    presences.sort((a, b) =>
    a.exitTime!.isBefore(b.exitTime!) ? -1 : 1);

    DateTime? inf=presences.first.exitTime;
    DateTime? sup=presences.last.exitTime;
    return [inf!,sup!];
  }


  Future<Map<String, double>> getExitStatisticsInRange(
      {required DateTime start,required DateTime end,
        required String employeeId,int num=4

      }) async {
    QuerySnapshot querySnapshot;
    querySnapshot= await _presence
        .where('date',isGreaterThanOrEqualTo: utils.formatDateTime(start))
        .where('date',isLessThanOrEqualTo: utils.formatDateTime(end))
        .where('employee_id',isEqualTo: employeeId)
        .get()
    ;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).where((presence) => presence.exitTime!=null).toList();
    if(presences.isEmpty) return {};
    presences.sort((first, second) =>
        first.exitTime!.compareTo(second.exitTime!));

    var limits=await getExitTimeLimits(start, end);
    if(limits.isEmpty) return {};



     DateTime inf=limits[0];
     DateTime sup=limits[1];

     inf=utils.roundToPreviousHour(inf);
     sup=utils.roundToNextHour(sup);

    var exitIntervals=subdivideDateTimeInterval(inf, sup, num);
    int total=presences.length;
    Map< String,double> statistics={};


    for(var interval in exitIntervals){
      statistics[utils.getTimeRangesAsStr(interval)]=
      (presences.where((presence) =>
          presence.isExitInRange(interval)).length*100.0/total).
        roundToDouble();
    }
    return statistics;
  }



  Future<List<Map<String, double>>> getMonthlyStatisticsInRange(
      DateTime month,String employeeId) async {

    DateTime
        start=DateTime(month.year,month.month,1),
        end=DateTime(month.year,month.month,utils.lengthOfMonth(month));

    return getStatisticsInRange(start: start, end: end, employeeId: employeeId);
  }


  Future<List<Map<String, double>>> getStatisticsInRange(
      {required DateTime start,required DateTime end,
        required String employeeId

      }) async {

    return [
      await getEntryStatisticsInRange(start: start, end: end, employeeId: employeeId),
      await getExitStatisticsInRange(start: start, end: end, employeeId: employeeId)
    ];
  }


  List<List<DateTime>> subdivideDateTimeInterval
      (DateTime inf, DateTime sup, int num) {
    Duration interval = sup.difference(inf) ~/ num;
    List<DateTime> result = [];

    for (int i = 0; i < num; i++) {
      DateTime dateTime = inf.add(interval * i);
      result.add(dateTime);
    }
    result.add(sup);

    List<List<DateTime>> intervalBounds = [];

    for (int i = 0; i < result.length - 1; i++) {
      List<DateTime> bounds = [result[i], result[i + 1]];
      intervalBounds.add(bounds);
    }

    return intervalBounds;
  }


  Future<List<Presence>> getPeriodicPresenceReport(
      {required DateTime start,required DateTime
      end,
        List<String> status=const['present','late' ],
        List<String>? services,
        List<String>? employeesIds
      }
      )
  async {

    List<Presence> presences;

    if(services==null&&employeesIds==null)
    {
      presences=await getAllPeriodicPresenceRecords(
          start: start, end: end,status:status);
    }

    else
    {
      if(services!=null)
      {
        presences= await getSomeServicesPeriodicPresenceReport
          (start: start, end: end, services: services,status: status);

      }
      else//employeesIds!=null
          {
        presences=await getSomeEmployeesPeriodicPresenceRecords
          (start: start, end: end, employeesIds: employeesIds!,status: status);
      }

    }
    return presences;

  }

//check and solve the issue
  Future<List<Presence>> getMonthPresenceRecords
      (String employeeId,DateTime date) async {
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);

    if(!date.isAtSameMomentAs(today)) {

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
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);
    if(!date.isAtSameMomentAs(today)) {
      date=DateTime(date.year,date.month,utils.lengthOfMonth(date));
    }
    String start=utils.formatDateTime(DateTime(date.year,date.month,1));
    String end=utils.formatDateTime(date);
    QuerySnapshot querySnapshot = await _presence
        .where('date', isGreaterThanOrEqualTo:start )
        .where('date',isLessThanOrEqualTo: end).
    get();


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

    _presence.doc(id).update({'entry_time':utils.formatTime(dateTime)});
  }
  void updateExitTime(String id,DateTime dateTime){
    _presence.doc(id).update({'exit_time':utils.formatTime(dateTime)});
  }
  void updateService(String id,String service){

    _presence.doc(id).update({'employee_service':service});
  }
  void updateStatus(String id,EStatus status){

    _presence.doc(id).update({'status':utils.str(status)});
  }
  void markEntry(Employee employee,DateTime dateTime) async {

String employeeId=employee.id;
  EStatus status=employee.isLate(dateTime)?EStatus.late:EStatus.present;

  String? presenceId= await getEmployeePresenceId(employeeId, dateTime);
updateEntryTime(presenceId!, dateTime);
updateStatus(presenceId, status);
EmployeeDB().updateCurrentStatus(employeeId, status);

  }

  Future<int> markExit(Employee employee,DateTime dateTime) async {

    DateTime today=DateTime(dateTime.year,dateTime.month,dateTime.day);
    String employeeId=employee.id;
    String? presenceId= await getEmployeePresenceId(employeeId, today);


    if(employee.desiresToExitBeforeEntryTime(dateTime)) {
      log.d('Yeah desire to exit before entry time');
      currentPresenceId=presenceId!;
      return desiresToExitBeforeEntryTime;
    }
    if(employee.desiresToExitBeforeExitTime(dateTime)) {
      log.d('Yeah desire to exit early');
      currentPresenceId=presenceId!;
      return desiresToExitBeforeExitTime;
    }
    updateExitTime(presenceId!, dateTime);
    EmployeeDB().updateCurrentStatus(employeeId, EStatus.out);
    return exitMarkedSuccessfully;

  }

  Future<String?> getEmployeePresenceId(String employeeId, DateTime date) async {

    QuerySnapshot querySnapshot = await _presence
        .where('employee_id', isEqualTo: employeeId)
        .where('date',isEqualTo: utils.formatDateTime(date))
        .limit(1)
        .get();


    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;

  }
  Future<void> setAttendance(String employeeId,DateTime date) async {
    EStatus status;

    Employee employee=await EmployeeDB().getEmployeeById(employeeId);

    if(employee.startDate.isAfter(date)){
    return;
    }

    if(
    employee.startDate.isAtSameMomentAs(date)){
      EmployeeDB().updateCurrentStatus(employeeId, EStatus.absent);
    }

    if(utils.isWeekend(date)) {
      status=EStatus.inWeekend;
    }
    else if(await HolidayDB().isInHoliday(employeeId, date)) {
      status=EStatus.inHoliday;
    }



    else{
      status=EStatus.absent;

    }
    Presence presence=Presence(
        date: date, employeeId: employeeId, status: status,
    employeeService: employee.service);


    await create(presence);

    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);

    if(date.isAtSameMomentAs(today)){

      EmployeeDB().updateCurrentStatus(employeeId, status);
    }
  }

  Future<List<double>> getCount(String employeeId,DateTime date) async {
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);
    date=DateTime(date.year,date.month,date.day);
    if(!date.isAtSameMomentAs(today)) {
      //log.d('Not this month');
      date=DateTime(date.year,date.month,utils.lengthOfMonth(date));
    }
    String start=utils.formatDateTime(DateTime(date.year,date.month,1));
    String end=utils.formatDateTime(date);
    QuerySnapshot querySnapshot = await _presence
        .where('employee_id',isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo:start )
        .where('date',isLessThanOrEqualTo: end)
        .where('status',whereIn: ['present','late','absent'])
        .orderBy('date')
        .get()
    ;


    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();
    int total=presences.length;

   int pre= presences.where((doc) =>doc.status==EStatus.present ).length;
  int late= presences.where((doc) =>doc.status==EStatus.late ).length;
  int abs= presences.where((doc) =>doc.status==EStatus.absent ).length;


    return total==0?[0,0,0]:[100*pre/total,100*late/total,100*abs/total];
  }




  Future<List<double>> getServiceReport(String service) async {
    DateTime now=await utils.localTime();
    DateTime today=DateTime(now.year,now.month,now.day);

    String end=utils.formatDateTime(DateTime(today.year,today.month,today.day));
    String start=utils.formatDateTime(DateTime(today.year,today.month));

    QuerySnapshot querySnapshot = await _presence
        .where('date', isGreaterThanOrEqualTo:start )
        .where('date',isLessThanOrEqualTo: end)
        .where('status',whereIn: ['present','late','absent'])
        .orderBy('date')
        .get()
    ;

    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    List<Presence> filteredPresences=[];
    for (var doc in presences) {

      Employee employee = await EmployeeDB().getEmployeeById(doc.employeeId);

      if (employee.service == service) {

        filteredPresences.add(doc);
      }
    }


    int total=filteredPresences.length;



    int pre= filteredPresences.where((doc) =>doc.status==EStatus.present ).length;
    int late= filteredPresences.where((doc) =>doc.status==EStatus.late ).length;
    int abs= filteredPresences.where((doc) =>doc.status==EStatus.absent ).length;

    return total==0?[0,0,0]:[(100*pre/total).roundToDouble(),
      (100*late/total).roundToDouble(),(100*abs/total).roundToDouble()];
  }

  
  Future<Map<String, List<double>>> getServicesReport() async {
    var services=await ServiceDB().getServicesNames();
    Map<String,List<double>> report={};
    for(var service in services){
      report[service]= await getServiceReport(service);

    }
    return report;

  }


  Future<void> setAllEmployeesAttendances(DateTime date) async {
    var employees = await EmployeeDB().getAllEmployees();


    for (var employee in employees) {
      employee.id=(await EmployeeDB().getEmployeeIdByEmail(employee.email))!;

      await setAttendance(employee.id, date);
    }
  }

  Future<void> addServiceFieldToPresenceDocuments() async {
    QuerySnapshot querySnapshot = await _presence.get();

    Employee employee;
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();


    final batch = FirebaseFirestore.instance.batch();

    for (var doc in presences) {

      employee = await EmployeeDB().getEmployeeById(doc.employeeId);

      if (employee.id == doc.employeeId) {

        batch.update(_presence.doc(doc.id), {'employee_service': employee.service});
      }

    }
    await batch.commit();


    }


  Future<void>x() async {
    QuerySnapshot querySnapshot = await _presence.
    where('date',isEqualTo: '2023-07-11')
    .get();
    List<Presence> presences = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Presence.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in presences) {

        batch.update(_presence.doc(doc.id), {'status': 'absent'});
    }
    await batch.commit();


  }


    Future<void> setAllEmployeesAttendancesUntilCurrentDay() async {
    log.d("############## Yeh Bro");
      QuerySnapshot snapshot =await _lastUpdate.limit(1).get();
      DocumentSnapshot documentSnapshot = snapshot.docs[0];
      DocumentReference doc = documentSnapshot.reference;

      Map<String,dynamic> map=(await doc.get()).data()
      as  Map<String,dynamic>;

     String upd = map ['date']  ;

      var luDate=DateTime.parse(upd);


       DateTime now=await utils.localTime();
       DateTime today=DateTime(now.year,now.month,now.day);
       if(luDate.isAtSameMomentAs(today)){
         return;
       }

       var date=DateTime(luDate.year,luDate.month,luDate.day+1);


       while(!date.isAfter(today)){

         setAllEmployeesAttendances(date);

         date=date.add(const Duration(days: 1));
       }

       String lastUpdateId=( await _lastUpdate.limit(1).get()).docs.first.id;

       _lastUpdate.doc(lastUpdateId).update({'date':utils.formatDateTime(today)});
    }





  Future<Map<DateTime, EStatus>> getMonthReport
      (String employeeId, DateTime date) async {

  List<Presence> presenceDocuments=
  await getMonthPresenceRecords(employeeId, date);

   Map<DateTime, EStatus> report = {};
   for(Presence presence in presenceDocuments){
     report[presence.date]=presence.status;
   }
    return report;
  }

  Future<void> test() async {
    generatePresences('ezechieladede@gmail.com','Direction');
  }

  Future<void> generatePresences(String email,String service) async {
    String? employeeId = await EmployeeDB().getEmployeeIdByEmail(email);

    DateTime date = DateTime(2023, 5, 1);
    EStatus status = EStatus.present;
    Presence presence = Presence(
        date: date, employeeId: employeeId!, status: status);
    presence.employeeService=service;
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
      presence.employeeService=service;
      create(presence);
  }


}}
