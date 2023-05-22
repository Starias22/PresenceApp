import 'dart:core';

import 'package:presence_app/utils.dart';

class Planning {
  final utils = Utils();
  String _entryTime = "";
  String _exitTime = "";

  Planning(String entryTime, String exitTime) {
    _entryTime = entryTime;
    _exitTime = exitTime;
  }

  Planning.defaultp() {
    _entryTime = '08:00';
    _exitTime = '17:00';
  }

  Planning.define(this._entryTime, this._exitTime);

  void setEntryTime(String entryTime) {
    _entryTime = entryTime;
  }

  String getEntryTime() => _entryTime;

  void setExitTime(String exitTime) {
    _exitTime = exitTime;
  }

  String getExitTime() => _exitTime;

  bool equals(Planning p) {
    return _entryTime == p._entryTime && _exitTime == p._exitTime;
  }

  bool isValid() =>utils.checkFormat(_entryTime) && utils.checkFormat(_exitTime);

  Map<String, dynamic> toMap() =>
      {'entry_time': _entryTime, 'exit_time': _exitTime};


}
