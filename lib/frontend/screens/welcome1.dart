import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                Text("Bienvenue",
                  style: GoogleFonts.pinyonScript(
                    color: Colors.black,
                    fontSize: 34,
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("IMSP",
                      style: GoogleFonts.tangerine(
                        color: const Color(0xFF0020FF),
                        fontSize: 30,
                        fontWeight: FontWeight.w900
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(" Dangbo",
                        style: GoogleFonts.smokum(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("PresenceApp",
                    style: GoogleFonts.alexBrush(
                      color: const Color(0xFF0020FF),
                      fontSize: 35,
                      //fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text("Votre application qui vous permet de marquer et de suivre les presences...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tangerine(
                      fontSize: 25
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Center(
                    child: Image.asset('assets/images/people.jpg', fit: BoxFit.cover,
                      //width: MediaQuery.of(context).size.width*0.75,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: SizedBox(
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
