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
  String? pictureDownloadUrl;
  late String id, firstname, lastname, email, gender;
  int? fingerprintId;
  EStatus status;
  late DateTime startDate;
  late String serviceId;
  late String service;

  late String entryTime, exitTime;
  DateTime? today;

  Employee(
      {
        this.id='',
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
        this.fingerprintId,
        this.pictureDownloadUrl
      });

  Map<String, dynamic> toMap() => {
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
    'picture_download_url':pictureDownloadUrl
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
      pictureDownloadUrl: map['picture_download_url']
    );
  }

  bool isInRange(DateTime currentTime){
    DateTime currentdTime=DateTime(2000,1,1, currentTime.hour, currentTime.minute);

    return  (utils.format(entryTime)!.isBefore(currentdTime)||
        utils.format(entryTime)!.isAtSameMomentAs(currentdTime));
  }

  bool isLate(DateTime currentTime){

    DateTime currentdTime=DateTime(2000,1,1, currentTime.hour, currentTime.minute);

    return utils.format(entryTime)!.isBefore(currentdTime) ;
  }

  bool desiresToExitBeforeEntryTime(DateTime currentTime) {
    DateTime currentdTime=DateTime(2000,1,1, currentTime.hour, currentTime.minute);

    return currentdTime.isBefore(utils.format(entryTime)!);
  }
  bool desiresToExitBeforeExitTime(DateTime currentTime){
    DateTime currentdTime=DateTime(2000,1,1, currentTime.hour, currentTime.minute);

    return currentdTime.isBefore(utils.format(exitTime)!);
  }
}
