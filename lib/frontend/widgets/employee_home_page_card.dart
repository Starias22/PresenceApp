import 'package:flutter/material.dart';

class HomePageCard extends StatelessWidget {
  final user;
  final String imageDownloadURL;

  const HomePageCard({Key? key, this.user, required this.imageDownloadURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Text(
        "My Home Page",
      ),
      elevation: 1,
      floating: true,
      forceElevated: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {},
            child: Hero(
              tag: imageDownloadURL,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(imageDownloadURL),
              ),
            ),
          ),
        )
      ],
    );
  }

}
