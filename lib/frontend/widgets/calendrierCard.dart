import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

import '../../backend/new_back/models/employee.dart';
import '../../utils.dart';


class CalendrierCard extends StatelessWidget {
  Map<DateTime, EStatus> events;
  Function(DateTime) onCalendarChanged; // Ajoutez cette ligne
  DateTime minSelectedDate;

  CalendrierCard({Key? key, required this.events, required this.onCalendarChanged,required this.minSelectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel(

      onCalendarChanged: onCalendarChanged
        /* (DateTime newMonth) {

        log.d('Calendar changed');
        log.i('new month:$newMonth');
      },*/,
      maxSelectedDate: DateTime.now(),
      minSelectedDate: minSelectedDate,

      pageScrollPhysics: const NeverScrollableScrollPhysics(),
      locale: "fr",

      customDayBuilder: (
        bool isSelectable,
        int index,
        bool isSelectedDay,
        bool isToday,
        bool isPrevMonthDay,
        TextStyle textStyle,
        bool isNextMonthDay,
        bool isThisMonthDay,
        DateTime day,
      ) {
        // Récupérer l'état correspondant à la date du jour
        EStatus? event = events[day];


        Color color;
        if (utils.isWeekend(day)) {}

        if (event == EStatus.present) {
          color = Colors.green;
        } else if (event == EStatus.late) {
          color = Colors.yellow;
        } else if (event == EStatus.absent) {
          color = Colors.red;
        } else {
          color = Colors.white;
        }

        // Retourner le widget personnalisé
        return Container(
          decoration: BoxDecoration(
            color: color, //isSelectedDay ? Colors.grey : Colors.transparent,
            //borderRadius: BorderRadius.circular(0),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(
                color: Colors.black, //isSelectedDay ? Colors.white : color,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      daysHaveCircularBorder: false,
      //selectedDateTime: DateTime.now(),
      onDayPressed: (DateTime date, List<dynamic> events) {
        // print(date);
      },
      weekendTextStyle: const TextStyle(color: Colors.red),
      //selectedDayButtonColor: Colors.red,
    );
  }
}
