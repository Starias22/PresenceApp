import 'package:presence_app/utils.dart';

import 'employee.dart' as emp;

class Presence {
  late String id;

  late DateTime date;
  DateTime? entryTime;
  DateTime? exitTime;
  late emp.EStatus status;
  late String employeeId;

  Presence({this.id='',required this.date, this.entryTime, this.exitTime,
    required this.employeeId, required this.status});

  Map<String, dynamic> toMap() =>
      {
        'date': utils.formatDateTime(date),
        'entry_time': entryTime==null?null : utils.formatTime(entryTime!),
        'exit_time': exitTime==null?null :utils.formatTime(exitTime!),
        'status': utils.str(status),
        'employee_id': employeeId
      };

  static Presence fromMap(Map<String, dynamic> map) {
    return Presence(date: DateTime.parse(map['date']),
        status: utils.convertES(map['status']),
        employeeId: map['employee_id'],
    entryTime:map['entry_time']==null?null: utils.format(map['entry_time']),
        exitTime:map['exit_time']==null?null: utils.format(map['exit_time'],
            //id: map['id']
        ));
  }
}