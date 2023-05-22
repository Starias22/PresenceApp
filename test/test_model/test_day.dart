import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/backend/models/day.dart';
import 'package:presence_app/utils.dart';

void main() {
  group('Day tests', () {
    test('Day constructor sets correct values', () {
      Day day = Day('2023-03-15');
      expect(day.getDate(), '2023-03-15');
      expect(day.getMonth(), 3);
      expect(day.getDayOfMonth(), 15);
      expect(day.getweekday(), DateTime.wednesday);
      expect(day.isWeekend(), false);
      expect(day.getStatus(), DStatus.workday);
      expect(day.isValid(), true);
    });

    test('Day.today() returns current date', () {
      DateTime now = DateTime.now();
      String expectedDate =
          '${now.year}-${utils.formatTwoDigits(now.month)}-${utils.formatTwoDigits(now.day)}';

      Day day = Day.today();
      expect(day.getDate(), expectedDate);
      expect(day.isValid(), true);
    });

    test('Day.setDate() updates date and other properties', () {
      Day day = Day('2023-03-15');
      day.setDate('2023-03-16');
      expect(day.getDate(), '2023-03-16');
      expect(day.getMonth(), 3);
      expect(day.getDayOfMonth(), 16);
      expect(day.getweekday(), DateTime.thursday);
      expect(day.isWeekend(), false);
      expect(day.getStatus(), DStatus.workday);
      expect(day.isValid(), true);
    });

    test('Day equals() compares dates correctly', () {
      Day day1 = Day('2023-03-15');
      Day day2 = Day('2023-03-15');
      Day day3 = Day('2023-03-16');

      expect(day1.equals(day2), true);
      expect(day1.equals(day3), false);
    });

    test('Day toMap() returns correct map', () {
      Day day = Day('2023-03-15');
      Map<String, dynamic> expectedMap = {'date': '2023-03-15', 'status': DStatus.workday};

      expect(day.toMap(), expectedMap);
    });
  });

 
}
