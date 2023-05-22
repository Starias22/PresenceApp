import 'dart:core';

import 'package:presence_app/utils.dart';

class Service {
  late String _name;

  Service(String name) {
    _name = name;
  }

  void setName(String name) {
    _name = name;
  }

  String getName() => _name;
  bool equals(Service service) => _name == service._name;

  bool isValid() => _name != '';

  Map<String, String> toMap() => {'name': _name};

  void logInformations() {
    log.i('Service name: $_name');
  }
}
