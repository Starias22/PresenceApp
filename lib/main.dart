import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/services/day_manager.dart';
import 'package:presence_app/backend/services/presence_manager.dart';
import 'package:presence_app/utils.dart' as u;
import 'package:presence_app/utils.dart';

import 'backend/services/planning_manager.dart';
import 'backend/services/service_manager.dart';
import 'firebase_options.dart';
import 'frontend/screens/welcome.dart';

final utils = u.Utils();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure Firebase options

  u.log.d('Start point of the app');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //AdminManager().test(); //db
  //AdminManager().test2; //login
  //ServiceManager().test();
  //PlanningManager().test();
  //DayManager().test();

//EmployeeManager().test();
 // log.d('Before test');
 //PresenceManager().test();
//log.d('Okay');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // useMaterial3: true,
      ),
      home: const Welcome(),
    );
  }
}
