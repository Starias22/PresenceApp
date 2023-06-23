import 'package:presence_app/backend/models/presence_report_model/presence_report.dart';
import 'package:presence_app/backend/models/presence_statistics/statistics_record.dart';

import 'package:presence_app/utils.dart';


class PresenceStatistics{

  Map<String?,List<StatisticsRecord>> statisticsRowsByService;
  bool? groupByService;
  List<String>?  services;
  DateTime? end;
  DateTime? start;
  DateTime? selectedDate;
  //date or period
  String date;


  ReportType reportPeriodType;
  late String fStatus;
  List<String>  fServices=[];
  late String fReportType;


  PresenceStatistics({required this.statisticsRowsByService,
    this.services, required this.date,required this.groupByService,
    this.reportPeriodType=ReportType.daily}){




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

}