import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/service.dart';
import 'package:presence_app/backend/services/employee_manager.dart';

class ListEmployeeController {
  static Future<List<Employee>> retrieveEmployees() async {
    var data = await EmployeeManager().getData() as Map;

    List<Employee> employees = [];
    Employee employee;
    data.forEach((key, childs) {
      employee = Employee.target(childs['email']);
      employee.setFname(childs['firstname']);
      employee.setLname(childs['lastname']);
      employee.setService(Service(childs['service']));

      employees.add(employee);
    });
    return employees;
  }
}
