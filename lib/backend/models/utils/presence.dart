import 'package:presence_app/utils.dart';

import 'employee.dart' as emp;

class Presence {
  late String id;

  late DateTime date;
  DateTime? entryTime;
  DateTime? exitTime;
  late emp.EStatus status;
  late String employeeId;
  late String employeeService;

  Presence({this.id='',required this.date, this.entryTime, this.exitTime,
    required this.employeeId, required this.status, this.employeeService=''});

  Map<String, dynamic> toMap() =>
      {
        'employee_service':employeeService,
        'date': utils.formatDateTime(date),
        'entry_time': entryTime==null?null : utils.formatTime(entryTime!),
        'exit_time': exitTime==null?null :utils.formatTime(exitTime!),
        'status': utils.str(status),
        'employee_id': employeeId
      };

  static Presence fromMap(Map<String, dynamic> map) {
    return Presence(
      employeeService: map['employee_service'],
        id: map['id'],
        date: DateTime.parse(map['date']),
        status: utils.convertES(map['status']),
        employeeId: map['employee_id'],
        entryTime:map['entry_time']==null?null: utils.format(map['entry_time']),
        exitTime:map['exit_time']==null?null: utils.format(map['exit_time']),
    );
  }
}