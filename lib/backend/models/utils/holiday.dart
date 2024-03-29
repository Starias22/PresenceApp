import 'package:presence_app/utils.dart';

enum HolidayType{
  permission,
  holiday,//jour férié
  leave,//congés
  disease, //maladie
  vacation,//vacances
  other//autres

}

class Holiday {


  HolidayType type;
  String? description;
  //if null, all employees are in holiday
  List <String>? employeesIds;
  DateTime? creationDate,lastUpdateDate;

  late String id;
  late DateTime startDate, endDate;
  Holiday({this.id='',required this.employeesIds, required this.startDate,
    required this.endDate,required this.type,this.description,
    required this.creationDate,
    required this.lastUpdateDate

  });

  Map<String, dynamic> toMap() => {
    'description':description,
    'start_date': utils.formatDateTime(startDate),
    'end_date': utils.formatDateTime(endDate),
    'employees_ids':employeesIds,
    'type':utils.str(type),
    'creation_date' :creationDate,
    'last_update_date' :lastUpdateDate,
  };
  String getRange(){
   if(startDate.isAtSameMomentAs(endDate)) {
     return utils.frenchFormatDate(startDate);
   }
   return 'Du ${utils.frenchFormatDate(startDate)}'
       ' au ${utils.frenchFormatDate(endDate)}';
  }

  static Holiday  fromMap(Map<String, dynamic> map) {
    return Holiday(
      id:map['id'],
      description:map['description'],
      type: utils.convertHoliday(map['type']),

      startDate: utils.parseDate(map['start_date']),
      endDate:utils.parseDate(map['end_date']),
      // employeesIds: map['employees_ids'],
      employeesIds: List<String>.from(map['employees_ids'] ?? []),

      creationDate: map['creation_date'].toDate(),
      lastUpdateDate: map['last_update_date'].toDate(),
    );
  }
}
