import 'package:presence_app/main.dart';

enum EStatus { present, late, absent, out, inHoliday, inWeekend,pending }

EStatus convertES(String status) {
  if (status == 'inWeekend') return EStatus.inWeekend;
  if (status == 'inHoliday') return EStatus.inHoliday;
  if (status == 'late') return EStatus.late;
  if (status == 'present') return EStatus.present;
  if (status == 'absent') return EStatus.absent;
  /*if (status == 'notYet')*/ return EStatus.pending;

}

class Employee {
  late String id, firstname, lastname, email, gender, fingerprint;
  EStatus status;
  late DateTime startDate;

  late String image;
  late String serviceId;
  late String service;

  late String entryTime, exitTime;


  Employee(
      {this.id='',
      required this.firstname,
      required this.gender,
      required this.lastname,
      required this.email,
      this.serviceId='',
        this.service='',
      required this.startDate,
      required this.entryTime,
      required this.exitTime,
       this.status=EStatus.pending}){

    DateTime now=DateTime.now();
    DateTime today=DateTime(now.year,now.month,now.day);
    if(startDate.isAtSameMomentAs(today)) status=EStatus.absent;

  }

  Map<String, dynamic> toMap() => {
        'service':service,
        'status':utils.str(status),
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'service_id': serviceId,
        'entry_time': entryTime,
        'exit_time': exitTime,
        'gender': gender,
        'start_date': utils.formatDateTime( startDate),
      };

  static Employee fromMap(Map<String, dynamic> map) {
    return Employee(
      //id: map['id'],
      status: convertES(map['status']),
      firstname: map['firstname'],
      lastname: map['lastname'],
      email: map['email'],
      service: map['service'],
      serviceId: map['service_id'],
      entryTime: map['entry_time'],
      exitTime: map['exit_time'],
      startDate: DateTime.parse(map['start_date']),
      gender: map['gender'],
    );
  }
}
