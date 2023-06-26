import 'package:presence_app/backend/models/presence_report_model/presence_record.dart';
import 'package:presence_app/backend/models/utils/employee.dart';

import 'package:presence_app/utils.dart';

enum ReportType{
  daily,weekly,monthly,annual,periodic
}
class PresenceReport{

  Map<String?,List<PresenceRecord>> presenceRowsByService;
  bool? groupByService;
  List<String>?  services;
  DateTime? end;
  DateTime? start;
  DateTime? selectedDate;
  //date or period
  String date;
  EStatus? status;

  ReportType reportPeriodType;
  late String fStatus;
  List<String>  fServices=[];
  late String fReportType;


  PresenceReport({required this.presenceRowsByService,
    this.services, required this.date,
    this.status,required this.groupByService,required this.reportPeriodType}){


    if(status==null) {
      fStatus='Tous';
    }
    else {
      fStatus=utils.str(status);
    }
    if (services==null){
     fServices.add('Tous');
    }




    fReportType=utils.str(reportPeriodType);
    String x;
    if(reportPeriodType==ReportType.daily){
      x=date;
    }
    else if(reportPeriodType==ReportType.annual){
      x=start!.year.toString();
    }
    else if(reportPeriodType==ReportType.weekly||reportPeriodType==ReportType.periodic){
      x='Du ${utils.frenchFormatDate(start)} au ${utils.frenchFormatDate(end)}';
    }
    else //if(reportPeriodType==ReportType.monthly)
    {
      x='Mois de ${utils.month(start!)} ${start!.year}';
    }
    fReportType='Rapport de présence ${utils.str(reportPeriodType)}($x)';

  }

  bool isEmpty() {
    for (final value in presenceRowsByService.values) {
      if (value.isNotEmpty) {
        return false;
      }
    }
    return  true;
  }

}