import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/frontend/widgets/homePageUsersCard.dart';
import 'package:presence_app/utils.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
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

class _HomePageState extends State<HomePage> {
  Future<String>? imageDownloadURL;
  String? email=FirebaseAuth.instance.currentUser!.email;
  String? employeeId;
  String? filename;

  @override
  void initState() {
    super.initState();
    retrieve().then((_) {

      imageDownloadURL = getDownloadURL(filename!);
    });

    
  }
  
  Future<void> getImageName() async {
    final items = (await FirebaseStorage.instance.ref().listAll()).items;

    filename= items.where((item) => item.name.startsWith(RegExp('^$employeeId'))).toList()[0].name;
    log.d('filename... $filename');

  }
  Future<void> retrieve() async {
    employeeId=await EmployeeDB().getEmployeeIdByEmail(email!);
    await getImageName();
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User?>(context);

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
                    user: _user,
                    imageDownloadURL: snapshot.data!,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
