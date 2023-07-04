import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/presence.dart';
import 'package:presence_app/utils.dart';


class PresenceRecord{
  Employee employee;
  Presence presence;


  late String employeeName;
  late String entryTime;
  late String exitTime;
  late String workDuration;
  late String punctualityDeviation;
  late String exitDeviation;
  PresenceRecord({required this.employee, required this.presence})
  {
    employeeName='${employee.lastname } ${employee.firstname}';
    entryTime=presence.entryTime==null?'-':utils.formatTime(presence.entryTime!);
    exitTime=presence.exitTime==null?'-':utils.formatTime(presence.exitTime!);

    if(entryTime=='-'||exitTime=='-'){
      workDuration='';
    }
    else{
     workDuration=utils.abs(presence.entryTime!, presence.exitTime!);
    }

    // if(presence.entryTime!=null){
    //
    //   String deviation=utils.abs(presence.entryTime!,
    //       utils.format(employee.entryTime)!  );
    //
    //     if(deviation=='00:00'){
    //       punctualityDeviation=deviation;
    //
    //     }
    //     else if(presence.status==EStatus.late){
    //       punctualityDeviation='-$deviation';
    //     }
    //     else{
    //       punctualityDeviation='+$deviation';
    //     }
    //
    //
    // }
    // else{
    //   punctualityDeviation='-';
    // }
    punctualityDeviation=presence.punctualityDeviation(employee.entryTime);


    //
    // if(presence.exitTime!=null){
    //
    //   String deviation= utils.abs(presence.exitTime!, utils.format(employee.exitTime)!  );
    //
    //   if(deviation=='00:00'){
    //     exitDeviation=deviation;
    //
    //   }
    //   else if(presence.exitTime!.isBefore(utils.format(employee.exitTime)!)){
    //     exitDeviation='-$deviation';
    //   }
    //
    //   else{
    //     exitDeviation='+$deviation';
    //   }
    //
    //
    // }
    // else{
    //   exitDeviation='-';
    // }
exitDeviation=presence.exitDeviation(employee.exitTime);

  }

}