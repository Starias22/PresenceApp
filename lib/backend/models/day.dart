import 'dart:core';
import 'package:presence_app/utils.dart';

class Day {
  late String _date;
  late DStatus _status;
  late int _year,
      _month,
      _dayOfMonth,
      //the day of the week
      _weekday;
  late bool _weekend;

  Day(String date) {
   
    _date = date;
    var dTime = DateTime.parse(_date).toLocal();

    _year = dTime.year;
    _month = dTime.month; //[1-7]
    _dayOfMonth = dTime.day; //[1-31]
    _weekday = dTime.weekday;
    _weekend = utils.isWeekEnd(_weekday);
    _status = _weekend ? DStatus.weekend : DStatus.workday;
  }



  Day.day(int year,int month,int day) {
   
   
    _date = '$year-${utils.formatTwoDigits(month)}-${utils.formatTwoDigits(day)}';
    var dTime = DateTime.parse(_date).toLocal();

    _year = dTime.year;
    _month = dTime.month; //[1-7]
    _dayOfMonth = dTime.day; //[1-31]
    _weekday = dTime.weekday;
    _weekend = utils.isWeekEnd(_weekday);
    _status = _weekend ? DStatus.weekend : DStatus.workday;
  }

   int getLengthOfMonth() {
    return DateTime(_year, _month + 1, 0).day;
  }

  Day.today() {
    DateTime now = DateTime.now();
    log.d('In today');
    _date =
        '${now.year}-${utils.formatTwoDigits(now.month)}-${utils.formatTwoDigits(now.day)}';
    var dTime = DateTime.parse(_date).toLocal();
    _year = dTime.year;
    _month = dTime.month; //[1-7]
    _dayOfMonth = dTime.day; //[1-31]
    _weekday = dTime.weekday;
    _weekend = utils.isWeekEnd(_weekday);
    _status = _weekend ? DStatus.weekend : DStatus.workday;
    log.d('End of today');
  }

  void setDate(String date) {
    _date = date;
    var dTime = DateTime.parse(_date).toLocal();
    _year = dTime.year;
    _month = dTime.month; //[1-7]
    _dayOfMonth = dTime.day; //[1-31]
    _weekday = dTime.weekday;
    _weekend = utils.isWeekEnd(_weekday);
    _status = _weekend ? DStatus.weekend : DStatus.workday;
  }

  String getDate() => _date;

  void setStatus(DStatus status) {
    _status = status;
  }

  DStatus getStatus() => _status;

  int getYear() => _year;
  int getMonth() => _month;
  int getDayOfMonth() => _dayOfMonth;
  bool isWeekend() => _weekend;
  int getweekday() => _weekday;

  bool isValid() => utils.isValid(_date);

  bool equals(Day day) => _date == day._date;
  Map<String, dynamic> toMap() => {'date': _date, 'status': utils.str(_status)};
}
