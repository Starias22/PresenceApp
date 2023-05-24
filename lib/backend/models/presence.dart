import 'package:presence_app/utils.dart';

import 'day.dart';
import 'employee.dart';

class Presence {
  late Day _day;
  late Employee _employee;
  late EStatus _status;

  String? _entryTime;
  String? _exitTime;

  Presence(Day day, Employee employee) {
    _day = day;
    _employee = employee;
    
  }

  void setEmployee(Employee employee) {
    _employee = employee;
  }

  Employee getEmployee() => _employee;

  void setEntryTime(String entryTime) {
    _entryTime = entryTime;
  }

  String? getEntryTime() => _entryTime;

  void setStatus(EStatus status) {
    _status = status;
  }

  EStatus getStatus() => _status;

  void setDays(Day day) {
    _day = day;
  }

  Day getDay() => _day;

  void setExitTime(String exitTime) {
    _exitTime = exitTime;
  }

  String? getExitTime() => _exitTime;

  Map<String, dynamic> toMap() => {
        'employee': {'email':_employee.getEmail(),'service':_employee.getService().getName()},
        'day': _day.getDate(),
        'entry_time': _entryTime,
        'exit_time': _exitTime,
        'status': utils.str(_status)
      };

  bool isValid()=>  _employee.hasValidEmail()&&
                  _day.isValid();
  

  void logInformations() {
    log.i('Email of the employee:${_employee.getEmail()}');
    log.i('Date:${_day.getDate()}');
    log.i('entry time:$_entryTime');
    log.i('exit time:$_exitTime');
    log.i('Presence status:$_status');
  }

  
}
