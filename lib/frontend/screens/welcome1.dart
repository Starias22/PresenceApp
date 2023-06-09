import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/welcome.dart';

class WelcomeImsp extends StatefulWidget {
  const WelcomeImsp({Key? key}) : super(key: key);

  @override
  State<WelcomeImsp> createState() => _WelcomeImspState();
}

class _WelcomeImspState extends State<WelcomeImsp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(
                  builder: (BuildContext context) {return const Welcome();}
                  ));
                  },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    child: Text("Passer"),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height/10,),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Bienvenue à l'Institut de Mathématiques et de Sciences Physiques...",
                    style: TextStyle(
                      color: Colors.black,
                      //fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text("IMSP",
                  style: TextStyle(
                    color: Color(0xFF0020FF),
                    fontSize: 40,
                  ),
                ),
                Text("Dangbo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("data"),
                Center(
                  child: Image.asset('assets/images/time.png', fit: BoxFit.cover,),
                ),


              ],
            ),
          )
        ],
      ),
    );
  }
}
