// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/app_settings/app_settings.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/firestore/presence_db.dart';
import 'package:presence_app/backend/firebase/login_service.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/backend/models/utils/presence.dart';
import 'package:presence_app/frontend/screens/presence_details.dart';
import 'package:presence_app/frontend/screens/welcome.dart';
import 'package:presence_app/frontend/widgets/presence_calendar_card.dart';
import 'package:presence_app/frontend/widgets/custom_snack_bar.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';
import 'package:provider/provider.dart';

import 'employee_account.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({Key? key}) : super(key: key);

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}


class _EmployeeHomePageState extends State<EmployeeHomePage> {

  bool showMenu = false;
  Future<String>? img;
  String? email = FirebaseAuth.instance.currentUser!.email;
  String? filename;
  late Employee employee;

  late Presence presenceDoc;
  late DateTime startDate;
  bool isLoading = true;
  late DateTime now, today;
  late DateTime nEntryTime, nExitTime;
  bool operationInProgress = true;
  late Future<void> _retrieveFuture;

  onDayLongPressed(DateTime date) async {
    if (utils.isWeekend(date)) {
      ToastUtils.showToast(context, 'Weekend', 3);
    }

    if ((!utils.isWeekend(date)) &&
        (date.isBefore(today) || date.isAtSameMomentAs(today))) {
      String? presenceId = await PresenceDB().getPresenceId(date, employee.id);

      Presence myPresence = await PresenceDB().getPresenceById(presenceId!);


      if (myPresence.status == EStatus.absent) {
        ToastUtils.showToast(context, 'Absent', 3);
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                PresenceDetails(
                  presence: myPresence, nEntryTime: employee.entryTime,
                  nExitTime: employee.exitTime,
                  isAdmin: false,
                ),
          ),
        );
      }
    }
  }


  Future<void> onCalendarChanged(DateTime newMonth) async {
    setState(() {
      isLoading = true;
    });
    var newEventsData = await PresenceDB().getMonthReport(
        employee.id, newMonth);
    setState(() {
      _events = newEventsData;
      isLoading = false;
    });
  }


  Map<DateTime, EStatus> _events = {};


  Future<void> retrieveReport() async {
    log.i('Setting all employees attendance for today');
    await PresenceDB().setAllEmployeesAttendancesUntilCurrentDay();

    Map<DateTime, EStatus>x = {};
    nEntryTime = utils.format(employee.entryTime)!;
    nExitTime = utils.format(employee.exitTime)!;
    if (employee.status == EStatus.pending) {
      x[employee.startDate] = EStatus.pending;
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(
        simple: true,
        showCloseIcon: false,
        duration: const Duration(seconds: 5),
        message: 'Employé en attente',
      ));
    }
    now = await utils.localTime();
    today = DateTime(now.year, now.month, now.day);
    var y = (employee).startDate;
    if (x.isEmpty) {
      x = await PresenceDB().getMonthReport(employee.id, today);
    }


    setState(() {
      _events = x;
      startDate = y;
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _retrieveFuture = retrieve();

  }

  Future<String?> getImageName() async {
    if (employee.pictureDownloadUrl == null) {
      return null;
    }
    final items =
        (await FirebaseStorage.instance.ref().listAll()).items;

    log.d('The items: $items');

    return items.where((item) =>
        item.name.
        startsWith(RegExp('^${employee.id}'))).toList()[0].name;
  }


  Future<void> retrieve() async {
    employee = await EmployeeDB().getEmployeeByEmail(email!);

    filename = await getImageName();
    await retrieveReport();
  }


  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);
    return Theme(
        data: appSettings.isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(

            body:
            FutureBuilder(
                future: _retrieveFuture,
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Afficher le cercle indicateur de progression pendant le chargement
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    // Les données de l'employé sont disponibles, continuer avec le contenu de la page
                    return SafeArea(
                        child:
                        CustomScrollView(
                          slivers: [
                            SliverAppBar(


                              title: const Center(
                                  child: Text("Calendrier des présences")),
                              elevation: 1,
                              floating: true,
                              forceElevated: true,
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: MouseRegion(
                                    onEnter: (event) {},
                                    onExit: (event) {},
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          showMenu = true;
                                        });
                                      },
                                      child: Tooltip(
                                        message: 'Compte employé\n '
                                            '${employee.firstname} ${employee
                                            .lastname}\n'
                                            '${employee.email}',
                                        preferBelow: false,
                                        child: Hero(
                                          tag: '',
                                          child: CircleAvatar(


                                            backgroundColor: Colors.grey,

                                            backgroundImage: employee
                                                .pictureDownloadUrl == null
                                                ? Image
                                                .asset(
                                              'assets/images/imsp1.png',
                                              fit: BoxFit.fill,
                                            )
                                                .image
                                                : NetworkImage(
                                                employee.pictureDownloadUrl!),

                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (showMenu)
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == "logout") {
                                        // Handle déconnexion option

                                        await Login().googleSingOut();
                                        ToastUtils.showToast(
                                            context, 'Vous êtes déconnecté', 3);
                                        Future.delayed(
                                            const Duration(seconds: 3),
                                                () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(

                                                      builder: (context) =>
                                                          const WelcomeImsp()));
                                              Navigator.push(
                                                  context, MaterialPageRoute(
                                                  builder: (
                                                      BuildContext context) {
                                                    return const WelcomeImsp();
                                                  }));
                                            });
                                      }
                                      else if (value == "handle") {
                                        // Handle Gérer mon compte option
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (
                                                    context) => const EmployeeAccount()));
                                      }

                                      else if (value == "dark") {
                                        await Provider.of<AppSettings>(
                                            context, listen: false)
                                            .setDarkMode(
                                          !Provider
                                              .of<AppSettings>(
                                              context, listen: false)
                                              .
                                          isDarkMode,
                                        );
                                      }
                                      else if (value == "language") {
                                        // Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>  const MonCompte()));
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[

                                      const PopupMenuItem<String>(
                                        value: "handle",
                                        child: Text("Mon compte"),
                                      ),
                                      PopupMenuItem<String>(
                                        value: "dark",
                                        child: Text(appSettings.isDarkMode
                                            ? 'Mode lumineux'
                                            : 'Mode sombre'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: "language",
                                        child: Text("Langue"),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: "logout",
                                        child: Text("Déconnexion"),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        height: 500,
                                        // Replace 500 with the desired height
                                        child: PresenceCalendarCard(
                                          colorCalendar: false,
                                          events: _events,
                                          onDayLongPressed: onDayLongPressed,
                                          onCalendarChanged: onCalendarChanged,
                                          minSelectedDate: employee.startDate,
                                        ),
                                      ),
                                    ),
                                    // Other content...
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                    );
                  }
                }
            )
        )
    );
  }

}