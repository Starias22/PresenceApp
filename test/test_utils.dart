import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/utils.dart';

void main() {
  group('Utils tests', () {
    test('isValid() correctly validates dates', () {
      String dateString1 = '2023-05-11';
      String dateString2 = '2023/05/11';
      String dateString3 = 'invalid-date';

      expect(utils.isValid(dateString1), true);
      expect(utils.isValid(dateString2), false);
      expect(utils.isValid(dateString3), false);
    });

    test('utils.isWeekEnd() correctly identifies weekends', () {
      expect(utils.isWeekEnd(DateTime.saturday), true);
      expect(utils.isWeekEnd(DateTime.sunday), true);
      expect(utils.isWeekEnd(DateTime.monday), false);
      expect(utils.isWeekEnd(DateTime.tuesday), false);
      expect(utils.isWeekEnd(DateTime.wednesday), false);
      expect(utils.isWeekEnd(DateTime.thursday), false);
      expect(utils.isWeekEnd(DateTime.friday), false);
    });

    test('_formatTwoDigits() formats digits correctly', () {
      expect(utils.formatTwoDigits(1), '01');
      expect(utils.formatTwoDigits(10), '10');
      expect(utils.formatTwoDigits(9), '09');
    });

    test('Valid email returns true', () {
      expect(utils.isValidEmail('test@example.com'), true);
      expect(utils.isValidEmail('john.doe@gmail.com'), true);
      expect(utils.isValidEmail('foo123@bar.com'), true);
    });

    test('Invalid email returns false', () {
      expect(utils.isValidEmail('notanemail'), false);
      expect(utils.isValidEmail('test@example'), false);
      expect(utils.isValidEmail('john.doe@gmail'), false);
    });

    test('isValidName tests', () {
      test('Non-empty name returns true', () {
        //expect(utils.isValidName('John Doe'), true);
        //expect(utils.isValidName('Alice'), true);
      });

      /* test('Empty name returns false', () {
        expect(utils.isValidName(''), false);
      });*/

    });


    /*test('getNextNum tests', () {
      test('Returns correct next number when data is false', () {
        expect(utils.getNextNum(false, 'test'), 1);
      });

      test('Returns correct next number when data is a Map', () {
        Map<String, dynamic> data = {
          'test1': 1,
          'test2': 2,
          'test3': 3,
        };

        expect(utils.getNextNum(data, 'test'), 4);
      });

      test('Returns correct next number when data is not false or a Map', () {
        expect(utils.getNextNum('test', 'test'), 1);
        expect(utils.getNextNum(123, 'test'), 1);
        expect(utils.getNextNum(null, 'test'), 1);
      });
    });*/

  });
}
