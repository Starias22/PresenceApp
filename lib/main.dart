import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/frontend/screens/welcome.dart';


import 'package:presence_app/utils.dart' as u;
import 'package:presence_app/utils.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';



final utils = u.Utils();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure Firebase options

  u.log.d('Start point of the app');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//PresenceDB().remove();
  await PresenceDB().setAllEmployeesAttendancesUntilCurrentDay();




  log.d('Just after');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isDarkModeValue = prefs.getBool('isDarkMode');

  AppSettings appSettings = AppSettings();

  //await appSettings.loadSettings();

  if (isDarkModeValue != null) {

    appSettings.setDarkMode(isDarkModeValue);
    log.i('******${appSettings.isDarkMode}');
  }

  //await initializeDateFormatting('en_US', '');




  runApp(

      ChangeNotifierProvider.value(
        value: appSettings,
        //create: (context) => AppSettings(),
        //create: (_) => AppSettings(),
        child: const MyApp(),
      ));
}

class MyApp extends StatelessWidget {


  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return Consumer<AppSettings>(
        builder: (context, appSettings, _) {
          return MaterialApp(
            title: 'PresenceApp ',
            debugShowCheckedModeBanner: false,
            theme: appSettings.isDarkMode ? ThemeData.dark() : ThemeData(
              primarySwatch: Colors.blue,
              // useMaterial3: true,
            ),
            home: const Welcome(),
          );
        });
  }
}
