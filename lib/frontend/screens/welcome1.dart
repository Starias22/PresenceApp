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
                SizedBox(height: MediaQuery.of(context).size.height/20,),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Bienvenue à l'Institut de Mathématiques et de Sciences Physiques...",
                    style: TextStyle(
                      color: Colors.black,
                      //fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("IMSP",
                      style: TextStyle(
                        color: Color(0xFF0020FF),
                        fontSize: 30,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Dangbo",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("PresenceApp",
                    style: TextStyle(
                      color: Color(0xFF0020FF),
                      fontSize: 20,
                    ),
                  ),
                ),
                const Text("Votre application qui vous permet de marquer et de suivre les presences...",
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Center(
                    child: Image.asset('assets/images/time.png', fit: BoxFit.cover,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width*4/5,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF0020FF)),
                      ),
                        onPressed: (){
                          Navigator.push(context,MaterialPageRoute(
                              builder: (BuildContext context) {return const Welcome();}
                          ));
                        },
                        child: const Text("Commencer"),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
