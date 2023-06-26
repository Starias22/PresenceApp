import 'package:presence_app/backend/models/utils/employee.dart';


class StatisticsRecord{
  Employee employee;
   String presence;
   String absence;
   String late;
  late String employeeName;

  StatisticsRecord({required this.employee,required this.presence,
    required this.late,required this.absence})
  {
    employeeName='${employee.lastname } ${employee.firstname}';


  }

}