import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test addNumbers function', () {
    // Test case 1
    expect(addNumbers(2, 3), equals(5));

    // Test case 2
    expect(addNumbers(-1, 1), equals(0));

    // Test case 3
    expect(addNumbers(0, 0), equals(0));
  });
}

int addNumbers(int a, int b) {
  return a + b;
}