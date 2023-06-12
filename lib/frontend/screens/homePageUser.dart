import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:presence_app/frontend/widgets/homePageUsersCard.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User?>(context);

    return Scaffold(

        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              HomePageCard(user:  _user,),
            ],
          ),
        )
    );
  }
}
