import 'dart:typed_data';
import 'package:presence_app/utils.dart';

import 'service.dart';
import 'planning.dart';
import 'day.dart';

class Employee {
  late String _fname='', _lname='', _email='', _gender='', _fingerprint;
  late EStatus _currentStatus=EStatus.absent;

  late Uint8List _image;
  late Service _service=Service('Direction');
  late Planning _planning=Planning.defaultp();
  late Day _addDay=Day.today();

  Employee(String email, String fname, String lname, String gender) {
    _fname = fname;
    _lname = lname;
    _email = email;
    _gender = gender;
    _addDay = Day.today();
    
  }
  Employee.target(String email) {
    _email = email;
  }

  void setFingerprint(String fingerprint) {
    _fingerprint = fingerprint;
  }

  String getFingerprint() => _fingerprint;

  void setFname(String fname) {
    _fname = fname;
  }

  String getFname() => _fname;

  void setLname(String lname) {
    _lname = lname;
  }

  String getLname() => _lname;

  void setEmail(String email) {
    _email = email;
  }

  String getEmail() => _email;

  void setGender(String gender) {
    _gender = gender;
  }

  String getGender() => _gender;

  void setImage(Uint8List image) {
    _image = image;
  }

  Uint8List getImage() => _image;

  void setService(Service service) {
    _service = service;
  }

  Service getService() => _service;

  void setAddDay(Day date) {
    _addDay = date;
  }
    Day getAddDay() => _addDay;


  EStatus getCurrentStatus() => _currentStatus;

  void setCurrentStatus(EStatus status) {
    _currentStatus = status;
  }

  void setPlanning(Planning planning) {
    _planning = planning;
  }

  Planning getPlanning() => _planning;

  bool hasValidEmail() => utils.isValidEmail(_email);
  bool hasValidFname() => _fname != '';
  bool hasValidLname() => _lname != '';
  bool hasValidService() => _service.isValid();
  bool hasValidPlanning() => _planning.isValid();

  int isValid() {
    if (!hasValidEmail()) return invalidEmail;
    if (!hasValidFname()) return invalidFname;
    if (!hasValidLname()) return invalidLname;
    if (!hasValidService()) return invalidServiceName;
    if (!hasValidPlanning()) return invalidPlanning;

    return success;
  }

  Map<String, dynamic> toMap() => {
        'firstname': _fname,
        'lastname': _lname,
        'email': _email,
        'service': _service.getName(),
        'planning': _planning.toMap(),
        'add_day': _addDay.getDate(),
        'gender': _gender,
    
        /*'fingerprint': _fingerprint,
        'image': _image*/
      };

  bool equals(Employee other) {
    return _email == other.getEmail();
  }

  void logInformations() {
    log.i('Email:$_email');
    log.i('Firstname:$_fname');
    log.i('Lastname:$_lname');
    log.i('Service:${_service.getName()}');
    log.i('entry time:${_planning.getEntryTime()}');
    log.i('exit time:${_planning.getExitTime()}');
    log.i('add date:${_addDay.getDate()}');
  }

}
