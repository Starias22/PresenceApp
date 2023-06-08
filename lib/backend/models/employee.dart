
import 'package:presence_app/utils.dart';
//final t= DateTime.now();
enum EStatus { present, late, absent, out, inHoliday, inWeekend,pending }

EStatus convertES(String status) {

  if (status == 'inWeekend') return EStatus.inWeekend;
  if (status == 'inHoliday') return EStatus.inHoliday;
  if (status == 'late') return EStatus.late;
  if (status == 'present') return EStatus.present;
  if (status == 'absent') return EStatus.absent;
  if (status == 'out') return EStatus.out;
  /*if (status == 'pending')*/ return EStatus.pending;

}


class Employee {
  late String id, firstname, lastname, email, gender;
  int? fingerprintId;
  int uniqueCode;
  EStatus status;
  late DateTime startDate;

  late String image;
  late String serviceId;
  late String service;

  late String entryTime, exitTime;
   DateTime? today;



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
       this.status=EStatus.pending,
      this.uniqueCode=0,this.fingerprintId});
  bool isLate(DateTime currentTime){

    return utils.format(entryTime)!.isBefore(currentTime) ;

  }
  bool desireToExitEarly(DateTime currentTime){
    return currentTime.isBefore(utils.format(exitTime)!);
  }
  static x(){

  }

  Map<String, dynamic> toMap() => {
        'unique_code':uniqueCode,
        'fingerprint_id':fingerprintId,
        'service':service,
        'status':utils.str(status),
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'service_id': serviceId,
        'entry_time': entryTime,
        'exit_time': exitTime,
        'gender': gender,
        'start_date': utils.formatDateTime(startDate),
      };

  static Employee fromMap(Map<String, dynamic> map) {
    return Employee(
      fingerprintId: map['fingerprint_id'],
      id: map['id'],
      status: convertES(map['status']),
      firstname: map['firstname'],
      lastname: map['lastname'],
      email: map['email'],
      service: map['service'],
      serviceId: map['service_id'],
      entryTime: map['entry_time'],
      exitTime: map['exit_time'],
      startDate: utils.parseDate(map['start_date']),
      gender: map['gender'],
    );
  }
  bool isInRange(DateTime currentTime){
    print('Range');
   return  (utils.format(entryTime)!.isBefore(currentTime)||
        utils.format(entryTime)!.isAtSameMomentAs(currentTime));

  }

  bool desireToExitBeforeEntryTime(DateTime now) {
    return now.isBefore(utils.format(entryTime)!);
  }

}
