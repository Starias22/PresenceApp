import 'package:presence_app/backend/models/presence_report_model/presence_record.dart';
import 'package:presence_app/backend/models/utils/employee.dart';

import 'package:presence_app/utils.dart';

enum ReportType{
  daily,weekly,monthly,annual,periodic
}
class PresenceReport{

  Map<String?,List<PresenceRecord>> presenceRowsByService;
  bool? groupByService;
  late String formattedStartDate;
  late String formattedEndDate;
  List<String>?  services;
  DateTime? end;
  DateTime start;
  late String formatted;
 // DateTime? selectedDate;
  String date;
  EStatus? status;

  ReportType reportPeriodType;
  late String fStatus;
  List<String>  fServices=[];


  PresenceReport({required this.presenceRowsByService,
    required this.services, required this.date,
    required this.status,required this.groupByService,
    required this.reportPeriodType,required this.start,required this.end}){


    if(status==null) {
      fStatus='Tous';
    }
    else {
      fStatus=utils.str(status);
    }
    if (services==null){
     fServices.add('Tous');
    }

    String x,y;

     if(reportPeriodType==ReportType.annual){
    x=start.year.toString();
    y='Année: ';
    }
     else if(reportPeriodType==ReportType.monthly){
       x=utils.getMonthAndYear(start);
       y='Mois: ';
     }
     else if(reportPeriodType==ReportType.weekly){
       x=utils.frenchFormatDate(start);
       y='Semaine du: ';
     }
    else if(reportPeriodType==ReportType.daily){
      x=utils.frenchFormatDate(start);
      y='Date: ';

    }
    else {
       x=utils.frenchFormatDate(start);
       y='Date de début: ';
    }
    formattedStartDate=y+x;
    if(end!=null){
      formattedEndDate= 'Date de fin: ${utils.frenchFormatDate(end!)}';
    }



  }

  bool isEmpty() {
    for (final value in presenceRowsByService.values) {
      if (value.isNotEmpty) {
        return false;
      }
    }
    return  true;
  }
  List<PresenceReport> groupByDate( List<DateTime> targetDates){
    List<PresenceReport> z=[];
    for(var targetDate in targetDates){
    z.add(reduceReport(targetDate));
    }
    return z;
  }


  PresenceReport clone() {
    PresenceReport clonedReport =
    PresenceReport(presenceRowsByService:
    presenceRowsByService, date: date, groupByService: groupByService,
        reportPeriodType: reportPeriodType,
        start: start, end: end,status: status,services: services);


    return clonedReport;
  }
PresenceReport reduceReport(DateTime targetDate){
    var reducedReport=clone();

    reducedReport.presenceRowsByService={};
    List<PresenceRecord> reducedRecords;


  presenceRowsByService.forEach((service, records) {
    log.d('The service: $service');
    reducedRecords=records.where((presenceRecord) =>
        presenceRecord.presence.date.isAtSameMomentAs(targetDate)).toList();

    reducedReport.presenceRowsByService[service]=reducedRecords;
  });
  return reducedReport;
}
}