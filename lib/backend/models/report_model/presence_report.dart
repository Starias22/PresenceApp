import 'package:presence_app/backend/models/report_model/presence_record.dart';


class PresenceReport{
  List<PresenceRecord> presenceRows;
  String? service;
  //date or period
  String date;


  PresenceReport({required this.presenceRows,this.service, required this.date});

}