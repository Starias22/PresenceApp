import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/backend/models/employee.dart';


void main() {
  String email = 'example@gmail.com', fname = 'John', lname = 'Doe';
  var employee = Employee(email, fname, lname, 'M');
  test('Test Employee constructor', () {
    expect(employee, isNotNull);
    expect(employee.getEmail(), equals(email));
    expect(employee.getFname(), equals(fname));
    expect(employee.getLname(), equals(lname));
    expect(employee.getGender(), equals('M'));
  });

  test('Test Employee.target', () {
   employee= Employee.target(email);
  expect(employee, isNotNull);

  expect(employee.getEmail(), equals(email));

  });
}
