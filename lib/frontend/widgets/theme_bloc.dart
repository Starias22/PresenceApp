import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ThemeEvent { toggle }

class ThemeBloc extends Bloc<ThemeEvent, ThemeData> {
  ThemeBloc() : super(ThemeData.light());

  @override
  Stream<ThemeData> mapEventToState(ThemeEvent event) async* {
    if (event == ThemeEvent.toggle) {
      yield state == ThemeData.light() ? ThemeData.dark() : ThemeData.light();
    }
  }
}
