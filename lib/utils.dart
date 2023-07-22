import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:logger/logger.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/holiday.dart';

import 'backend/models/presence_report_model/presence_report.dart';




Future<DateTime> getBeninTime() async {
  FieldValue.serverTimestamp();
  final response = await http.get(Uri.parse('http://worldclockapi.com/api/json/utc/now'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final utcTime = DateTime.parse(json['currentDateTime']);
    const beninTimeZoneOffset = Duration(hours: 1);
    final beninTime = utcTime.add(beninTimeZoneOffset);
    return beninTime;
  } else {
    throw Exception('Failed to fetch Benin time.');
  }
}




final utils = Utils();
bool darkMode=false;
const appBarColor=Color(0xFF0020FF);
 const double appBarTextFontSize=17;
const success = 0,
    invalidFirstname = 1,
    invalidLastname = 2,
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
    sameLastname = 39,
    networkError = 40,
    adminExists = 41,
    employeeExists = 42,
    newEmployee=43,
    espConnectionFailed=400,
    isWeekend=45,
    inHoliday=46,
    entryMarkedSuccessfully=47,
    exitMarked=48,
    entryAlreadyMarked=49,
    exitAlreadyMarked=50,
    exitMarkedSuccessfully=51,
    desireToExitEarly=52,
    desireToExitBeforeEntryTime=53,
    unsupportedFileExtension=54,

    noFingerDetected=150,
    noMatchingFingerprint=151,
    minFingerprintId=1,
    maxFingerprintId=127,
noInternetConnection=800



;

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
  DateTime getNextWorkDate(DateTime date) {
    int day;

    if (date.weekday == DateTime.friday) {
      // Friday
      day = date.day + 3;
    } else if (date.weekday == DateTime.saturday) {
      // Saturday
      day = date.day + 2;
    } else {
      // Other days
      day = date.day + 1;
    }
log.d(DateTime(date.year, date.month, day));
    return DateTime(date.year, date.month, day);
  }

  HolidayType convertHoliday(String type){
    if(type=='holiday') {
      return HolidayType.holiday;
    }
    if(type=='vacation') {
      return HolidayType.vacation;
    }
    if(type=='permission') {
      return HolidayType.permission;
    }
    if(type=='leave') {
      return HolidayType.leave;
    }
    if(type=='disease') {
      return HolidayType.disease;
    }
    // if(type=='other') {
      return HolidayType.other;
    // }
  }
  DateTime add30Days(DateTime date) {
    return date.add(const Duration(days: 30));
  }
  DateTime addAYear(DateTime date) {
    return date.add(const Duration(days: 30*12));
  }

  String frenchFormatDate(DateTime? dateTime) {
    if(dateTime==null) return 'JJ/MM/AAAA';
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  String x(Duration duration){

    String formattedTime = '${(duration.inHours).toString().
    padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';


    return formattedTime;

  }
  String abs(DateTime first , DateTime second){
    var duration=first.difference(second).abs();
    return x(duration);

  }

  DateTime roundToPreviousHour(DateTime dateTime) {

    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, 0);
  }
  DateTime roundToNextHour(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour+1, 0);
  }


  DateTime getWeeksMonday(DateTime aDateInTheWeek) {
    // Calculate the number of days to subtract to get to the previous Monday
    int daysToMonday = aDateInTheWeek.weekday - DateTime.monday;
    if (daysToMonday < 0) {
      daysToMonday += 7; // Adjust for negative values
    }

    // Subtract the calculated duration from the input date
    return aDateInTheWeek.subtract(Duration(days: daysToMonday));
  }


  DateTime getWeeksFriday(DateTime aDateInTheWeek){


    int day;
    if(aDateInTheWeek.weekday==DateTime.saturday) {
      day=-1;
    }
    if(aDateInTheWeek.weekday==DateTime.sunday) {
      day=-2;
    }

    else {
      day=5-aDateInTheWeek.weekday;
    }

    return aDateInTheWeek.add(Duration(days: day));
  }

  bool isWeekEnd(int weekday) {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }
  String y(ReportType reportType){
    if(reportType==ReportType.daily) return 'Journalier';
    if(reportType==ReportType.weekly) return 'Hebdomadaire';
    if(reportType==ReportType.monthly) return 'Mensuel';
    if(reportType==ReportType.annual) return 'Annuel';
    if(reportType==ReportType.periodic) return 'Autre période';
    return'Unknown';

  }

  Future<DateTime> localTime() async {
    CollectionReference timeCollection =
    FirebaseFirestore.instance.collection('time');

    QuerySnapshot snapshot = await timeCollection.limit(1).get();

      DocumentSnapshot documentSnapshot = snapshot.docs[0];
      DocumentReference timeDoc = documentSnapshot.reference;

      await timeDoc.update({'time': FieldValue.serverTimestamp()});

      // Retrieve the updated document
       documentSnapshot = await timeDoc.get();
      Timestamp? serverTimestamp =
      (documentSnapshot.data() as Map<String,dynamic>)['time'] as Timestamp?;


        DateTime currentServerTime = serverTimestamp!.toDate();
        return currentServerTime.subtract(const Duration(hours: 1));

  }

  String str(dynamic enm) {
    return enm.toString().split('.')[1];
  }

  String formatDateTime(DateTime dateTime){

    String formattedDate = '${dateTime.year}-'
        '${formatTwoDigits(dateTime.month)}-${formatTwoDigits(dateTime.day)}';

   return formattedDate;
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

  int getNextNum(List<String> data, String name) {
    if (data.isEmpty) return 1;

    List<int> intKeys =
        data.map((key) => int.parse(key.replaceAll(name, ''))).toList();

    int maxValue =
        intKeys.reduce((value, element) => value > element ? value : element);
   
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
  //sum  lists of same number of lists of integers with same numbers of items
  List<int> sum(List<List<int>> dbList){
    int n=dbList.length,m=dbList.first.length;



    List<int> sm=[];
    for(int j=0;j<m;j++) {
      sm.add(0);
      for (int i = 0; i < n; i++) {


        sm[j] += dbList[i][j];
      }
    }
    return sm;
  }

  bool isWeekend(DateTime date){
    return date.weekday == DateTime.saturday||date.weekday==DateTime.sunday;

  }
  ReportType convert (String type){
    if(type=='daily') return ReportType.daily;
    if(type=='weekly') return ReportType.weekly;
    if(type=='monthly') return ReportType.monthly;
    if(type=='annual') return ReportType.annual;
    /*if(type=='daily')*/ return ReportType.periodic;

  }
  String day(DateTime date){

    if(date.weekday==DateTime.monday) return 'Lundi';
    if(date.weekday==DateTime.tuesday) return 'Mardi';
    if(date.weekday==DateTime.wednesday) return 'Mercredi';
    if(date.weekday==DateTime.thursday) return 'Jeudi';
    if(date.weekday==DateTime.friday) return 'Vendredi';
    if(date.weekday==DateTime.saturday) return 'Samedi';
    /*if(date.weekday==DateTime.sunday)*/ return 'Dimanche';

  }

  String getTimeRangesAsStr(List<DateTime> times){

    return '${utils.formatTime(times[0])}-${utils.formatTime(times[1])}';

  }
  String getMonthAndYear(DateTime date){
    String month;

    if(date.month==DateTime.january) {
      month=  'Janvier';
    } else if(date.month==DateTime.february) {
      month=  'Février';
    } else if(date.month==DateTime.march) {
      month=  'Mars';
    } else if(date.month==DateTime.april) {
      month=  'Avril';
    } else if(date.month==DateTime.may) {
      month=  'Mai';
    } else if(date.month==DateTime.june) {
      month=  'Juin';
    } else if(date.month==DateTime.july) {
      month=  'Juillet';
    } else if(date.month==DateTime.august) {
      month=  'Aout';
    } else if(date.month==DateTime.september) {
      month=  'Septembre';
    } else if(date.month==DateTime.october) {
      month=  'Octobre';
    } else if(date.month==DateTime.november) {
      month=  'Novembre';
    } else if(date.month==DateTime.december) {
      month=  'Décembre';
    } else {
      month='';
    }
    return '$month ${date.year}';

  }

  DateTime? format(String? timeString){
    if (timeString==null) return null;
    List<String> timeParts = timeString.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    DateTime dTime=DateTime(2000,1,1);
    DateTime dateTime = DateTime(dTime.year, dTime.month,dTime.day, hours, minutes);

    return dateTime;
  }
  int lengthOfMonth(DateTime date){
    return DateTime(date.year,date.month+1,0).day;
  }

  DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('-');

    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    return DateTime(year, month, day);
  }


  String formatTime(DateTime dateTime) {


    final localDateTime = dateTime;
    final hours = formatTwoDigits(localDateTime.hour);
    final minutes = formatTwoDigits(localDateTime.minute);

    return "$hours:$minutes";
  }

  // int generateRandomCode() {
  //   var random = Random();
  //   // Generates a random number between 100000 and 999999 (inclusive)
  //   var code = random.nextInt(900000) + 100000;
  //
  //   return code;
  // }

  Future<bool> netWorkAvailable() async {
    return  (await Connectivity().checkConnectivity() != ConnectivityResult.none);
  }
}
