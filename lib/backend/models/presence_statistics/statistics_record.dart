import 'package:presence_app/backend/models/utils/employee.dart';


class StatisticsRecord{
  Employee employee;
   String pre;
   String abs;
   String late;
  late String employeeName;

  StatisticsRecord({required this.employee,required this.pre,
    required this.late,required this.abs})
  {
    employeeName='${employee.lastname } ${employee.firstname}';


  }

}