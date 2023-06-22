import 'dart:core';

class Service {
  late String id, name;
  Service({this.id='', required this.name});

  Map<String, dynamic> toMap() => {'id':id,'name': name};


  static Service fromMap(Map<String, dynamic> map) {
    return Service(
        name: map['name'],
        id: map['id']
      );
  }
}
