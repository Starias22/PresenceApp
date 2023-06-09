import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                InkWell(
                  child: Container(
                    child: Image.asset('assets/images/imspapp.png', fit: BoxFit.cover,),
                  ),
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => const Welcome()));
                  },
                ),


              ],
            )
          ],
        ),
      ),
    );
  }
}
