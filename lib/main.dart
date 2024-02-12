import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/backend/firebase/firestore/company_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:presence_app/backend/models/utils/company.dart';
import 'package:presence_app/frontend/widgets/wrapperEmployee.dart';
import 'package:presence_app/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/firebase/firestore/presence_db.dart';
import 'firebase_options_merveil.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Firebase options
  log.d('Start point of the app');
  await Firebase.initializeApp(
    
    options: DefaultFirebaseOptions.currentPlatform,
  );
  CompanyDescription company=CompanyDescription
    (name: 'UM6P', email: 'um6p@um6p.ma',
      country: 'Morocco', city: 'Benguerir', subscribeStatus: true);
  log.d('Before');
  //await CompanyDB().create(company);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isDarkModeValue = prefs.getBool('isDarkMode');

  AppSettings appSettings = AppSettings();


  if (isDarkModeValue != null) {
    appSettings.setDarkMode(isDarkModeValue);
    log.i('******${appSettings.isDarkMode}');
  }

  runApp(
      MultiProvider(
        providers: [
          StreamProvider.value(
            initialData: null,
            value: Login().user,
          ),
        ],
        child: ChangeNotifierProvider.value(
          value: appSettings,
          //create: (context) => AppSettings(),
          //create: (_) => AppSettings(),
          child: const MyApp(),
        ),
      )
  );

}
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();


class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
        builder: (context, appSettings, _) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
              supportedLocales: const [
                Locale('en'), // Add your desired locales here, e.g., 'fr'
                Locale('fr'),
              ],
            navigatorObservers: [routeObserver],
            title: 'PresenceApp ',
            debugShowCheckedModeBanner: false,
            theme: appSettings.isDarkMode ? ThemeData.dark() : ThemeData(
              textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
              primarySwatch: Colors.blue,
              // useMaterial3: true,
            ),
            home: const Wrapper(),
          );
        }
        );
  }
}
