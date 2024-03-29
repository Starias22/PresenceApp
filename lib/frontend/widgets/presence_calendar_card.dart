import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import '../../utils.dart';


class PresenceCalendarCard extends StatelessWidget {

final  Map<DateTime, EStatus> events;
  final Function(DateTime) onCalendarChanged;
 final DateTime minSelectedDate;
final  Function(DateTime)? onDayLongPressed;
  final bool colorCalendar;


  const PresenceCalendarCard({Key? key,
    required this.events,
    required this.onCalendarChanged,
    required this.minSelectedDate,
    required this.onDayLongPressed,
    this.colorCalendar=true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel(
      onDayLongPressed:onDayLongPressed ,
      onCalendarChanged: onCalendarChanged,
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
        Color color = Colors.white;

        if(colorCalendar) {

          if (utils.isWeekend(day)) {}

          if (event == EStatus.present) {
            color = Colors.green;
          } else if (event == EStatus.late) {
            color = Colors.yellow;
          } else if (event == EStatus.absent) {
            color = Colors.red;
          }
          else if (event == EStatus.inHoliday) {
            color = Colors.blue;
          }

          else {
            color = Colors.white;
          }
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
      onDayPressed: (DateTime date, List<dynamic> events) {
        // print(date);
      },
      weekendTextStyle: const TextStyle(color: Colors.red),
      //selectedDayButtonColor: Colors.red,
    );
  }
}
