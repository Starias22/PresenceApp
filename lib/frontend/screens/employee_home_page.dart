import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/frontend/widgets/employee_home_page_card.dart';
import 'package:presence_app/utils.dart';
import 'package:provider/provider.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({Key? key}) : super(key: key);

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

Future<String> getDownloadURL(String fileName) async {
  try {
    return await FirebaseStorage.instance
        .ref()
        .child(fileName)
        .getDownloadURL();
  } catch (e) {
    return "";
  }
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  Future<String>? imageDownloadURL;
  String? email=FirebaseAuth.instance.currentUser!.email;
  //String? employeeId;
  String? filename;
  late Employee employee;


  @override
  void initState() {
    super.initState();
    retrieve().then((_) {

      imageDownloadURL = getDownloadURL(filename!);
    });

    
  }
  
  Future<void> getImageName() async {
    final items = (await FirebaseStorage.instance.ref().listAll()).items;

    filename= items.where((item) => item.name.startsWith(RegExp('^${employee.id}'))).toList()[0].name;
    log.d('filename... $filename');

  }
  Future<void> retrieve() async {

    employee= await EmployeeDB().getEmployeeByEmail(email!);
    //employeeId=employee.id;

    await getImageName();
    setState(() {
      imageDownloadURL = getDownloadURL(filename!);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<String>(
          future: imageDownloadURL,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CustomScrollView(
                slivers: [
                  HomePageCard(
                    employee:employee ,
                    imageDownloadURL: snapshot.data!,
                  ),
                  
                  //Text('Un texte')
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
