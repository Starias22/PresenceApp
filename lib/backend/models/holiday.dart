import '../../../main.dart';

class Holiday {
  //if null, all employees are in holiday
  String? employeeId;
  late String id;
  late DateTime startDate, endDate;
  Holiday({this.id='',this.employeeId, required this.startDate,
    required this.endDate});

  Map<String, dynamic> toMap() => {
    'start_date': utils.formatDateTime(startDate),
    'end_date': utils.formatDateTime(endDate),
    'employee_id':employeeId,

  };

  static Holiday  fromMap(Map<String, dynamic> map) {
    return Holiday(
      startDate: map['start_date'],
      endDate: map['end_date'],
      employeeId: map['employee_id'],
    );
  }
  
}
