import 'package:presence_app/utils.dart';

enum HolidayType{
  permission,
  holiday,//jour férié
  leave//congés
}

class Holiday {
  //if null, all employees are in holiday
  HolidayType type;
  String? description;
  String? employeeId;
  late String id;
  late DateTime startDate, endDate;
  Holiday({this.id='',this.employeeId, required this.startDate,
    required this.endDate,required this.type,this.description});

  Map<String, dynamic> toMap() => {
    'description':description,
    'start_date': utils.formatDateTime(startDate),
    'end_date': utils.formatDateTime(endDate),
    'employee_id':employeeId,

  };

  static Holiday  fromMap(Map<String, dynamic> map) {
    return Holiday(
      id:map['id'],
      description:map['description'],
      type: map['type'],
      startDate: map['start_date'],
      endDate: map['end_date'],
      employeeId: map['employee_id'],
    );
  }
  
}
