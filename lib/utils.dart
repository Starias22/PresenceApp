import 'package:email_validator/email_validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

int x = 0;
final utils = Utils();

const success = 0,
    invalidFname = 1,
    invalidLname = 2,
    invalidEmail = 3,
    invalidPassword = 4,
    emailExists = 5,
    emailNotExists = 6,
    emailInUse = 7,
    sameEmail = 8,
    emailInCorrect = 9,
    weekPassword = 10,
    failure = -1,
    wrongPassword = 11,
    emptyPassword = 12,
    tooManyRequests = 13,
    internalError = 14,
    invalidServiceName = 15,
    serviceExists = 16,
    serviceNotExists = 17,
    sameService = 18,
    planningNotExists = 19,
    planningExists = 20,
    invalidPlanning = 21,
    invalidNewPlanning = 22,
    samePlanning = 23,
    dayNotExists = 24,
    dayExists = 25,
    invalidDate = 26,
    networkRequestFailed = 27,
    accountDeleted = 28,
    newServiceExists = 29,
    sameDStatus = 30,
    presenceExists = 31,
    presenceNotExists = 32,
    invalidPresence = 33,
    emailNotVerified = 34,
    diffPass = 35,
    noService = 36,
    popupClosedByUser = 37,
    sameFName = 38,
    sameLname = 39,
    networkError = 40,
    adminExists = 41,
    employeeExists = 42;

Map<String, String> clientIds = {
  'web':
      '201787268026-gr0krbt221kpjdgu890hv7o9dveej867.apps.googleusercontent.com',
  'android':
      '201787268026-e3cmed14poitbpg97ikif660rlsvoquh.apps.googleusercontent.com'
};

const FirebaseOptions firebaseOptions = FirebaseOptions(
    appId: "1:201787268026:web:ce244d361d2fbc0fb25b83",
    apiKey: "AIzaSyAJfZJtZ43KALdAIGKJJ7bTPnL9wQsrq5w",
    projectId: "myapp-fd370",
    messagingSenderId: "201787268026",
    authDomain: "myapp-fd370.firebaseapp.com",
    databaseURL: "https://myapp-fd370-default-rtdb.firebaseio.com",
    storageBucket: "myapp-fd370.appspot.com",
    measurementId: "G-X2X7BS1GMD");

enum EStatus { present, late, absent, out, inHoliday, inWeekend }
//enum EStatus { present, late, absent, inHoliday, inWeekend }

enum DStatus { weekend, holiday, workday }

final log = Logger();

class Utils {
  bool isValid(String dateString) {
    try {
      DateTime.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isWeekEnd(int weekday) {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  String str(dynamic enm) {
    return enm.toString().split('.')[1];
  }

  DStatus convert(String status) {
    if (status == 'weekend') return DStatus.weekend;
    if (status == 'workday') return DStatus.workday;
    /* if (status == 'holiday')*/ return DStatus.holiday;
  }

  EStatus convertES(String status) {
    if (status == 'inWeekend') return EStatus.inWeekend;
    if (status == 'inHoliday') return EStatus.inHoliday;
    if (status == 'late') return EStatus.late;
    if (status == 'present') return EStatus.present;
    if (status == 'absent') return EStatus.absent;
    /*if (status == 'out')*/ return EStatus.out;
  }

  bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  bool isValidName(String name) {
    return name != '';
  }

  int getNextNum(dynamic data, String name) {
    if (data == false) return 1;

    List<String> keys = data.keys.toList();

    List<int> intKeys =
        keys.map((key) => int.parse(key.replaceAll(name, ''))).toList();

    int maxValue =
        intKeys.reduce((value, element) => value > element ? value : element);
    log.i('last num:$maxValue');
    return maxValue + 1;
  }

  String formatTwoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  bool checkFormat(String timeString) {
    RegExp regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return regex.hasMatch(timeString);
  }
}
