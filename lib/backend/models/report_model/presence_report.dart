import 'package:presence_app/backend/models/report_model/presence_record.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/utils.dart';

enum ReportType{
  daily,weekly,monthly,annual,other
}
class PresenceReport{
  List<PresenceRecord> presenceRows;
  List<String>?  services;
  DateTime? end;
  DateTime? start;
  //date or period
  String date;
  EStatus? status;
  bool? groupByService;
  ReportType reportPeriodType;
  late String fStatus;
  List<String>  fServices=[];
  late String fReportType;


  PresenceReport({required this.presenceRows,this.services, required this.date,
  this.status,this.groupByService,this.reportPeriodType=ReportType.daily}){
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
    else if(reportPeriodType==ReportType.monthly||reportPeriodType==ReportType.other){
      x='Du ${utils.frenchFormatDate(start)} au ${utils.frenchFormatDate(end)}';
    }
    else //if(reportPeriodType==ReportType.monthly)
    {
      x='${start!.month}/${start!.year}';
    }
    fReportType='${utils.str(reportPeriodType)}($x)';

  }

}