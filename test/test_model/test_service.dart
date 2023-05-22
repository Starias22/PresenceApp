import 'package:flutter_test/flutter_test.dart';
import 'package:presence_app/backend/models/planning.dart';
void main() {
  var p = Planning.defaultp();
  p.setEntryTime('08:15');

  var q = Planning.define('08:15', '5');

  test('Test Service', () {
    expect(p, isNotNull);
    expect(p.getEntryTime(), equals('08:15'));
    expect(p.getExitTime(), equals('17:00'));
    expect(p.isValid(), true);
    expect(q.isValid(), false);
    expect(q.equals(p), false);
    q.setExitTime('17:00');
    p.setEntryTime('09:00');
    q.setEntryTime('09:00');
      expect(q.equals(p), true);

  });
}
