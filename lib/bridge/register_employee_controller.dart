import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/planning.dart';
import 'package:presence_app/backend/models/service.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/backend/services/service_manager.dart';
import 'package:presence_app/utils.dart';

class RegisterEmployeeController {
  static Future<int> register(String fname, String lname, String email,
      String gender, String service, entryTime, exitTime) async {
    Service serv = Service(service);
    Employee employee = Employee(email, fname, lname, gender);
    Planning planning = Planning(entryTime, exitTime);
    employee.setService(serv);
    employee.setPlanning(planning);
    log.d(planning.getEntryTime());
    log.d('Inside the controller');
    EmployeeManager employeeManager = EmployeeManager();
    return await employeeManager.create(employee);
  }

  static getServices() async {
    dynamic data = await ServiceManager().getData();

    if (data==false) {
      return noService;
    }
    var x = data as Map<String, dynamic>;
    List<String> services = [];
    x.forEach((key, values) {
      services.add(values['name']);
    });

    return services;
  }
}
