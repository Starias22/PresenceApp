import 'package:flutter/material.dart';

class HomePageCard extends StatelessWidget {
  final user;
  const HomePageCard({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Text("My Home Page",),
      elevation: 1,
      floating: true,
      forceElevated: true,

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: (){

            },
            child: Hero(
              tag: user!.photoURL!,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            ),
          ),
        )
      ],
    );
  }
}
