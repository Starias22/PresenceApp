// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/esp32.dart';
import 'package:presence_app/frontend/screens/register_employee.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/custom_message.dart';
import 'package:presence_app/utils.dart';

class EnrollFingerprint extends StatefulWidget {
  final Employee employee;
  const EnrollFingerprint({Key? key,
  required this.employee}) : super(key: key);

  @override
  State<EnrollFingerprint> createState() => _EnrollFingerprintState();
}

class _EnrollFingerprintState extends State<EnrollFingerprint> {
  int? fingerprintId;
  bool enrollmentInProgress=false;
  bool started=false;
  bool creationInProgress=false;
  String message ="Cliquez sur démarrer ...";
  String buttonText='Démarrer';
  bool cancelled=false;
  int colorCode=1;

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,
                semanticLabel: 'Précédent',),
                onPressed: () =>
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                             RegisterEmployee(employee:
                            widget.employee,))),
              ),
              backgroundColor: appBarColor,
              centerTitle: true,
              title: const Text(
                "Enregistrement d'empreinte",
                style: TextStyle(
                  fontSize: appBarTextFontSize,
                ),
              ),
            ),
          body:
          Column(
            children: [

              SizedBox(height: MediaQuery.of(context).size.height *0.05),
              Center(
                child: CustomMessage.
                getText(widget.employee.fingerprintId==null?
                message:"Un instant!!!",
                colorCode: colorCode),
              ),
              if(enrollmentInProgress)
                const CircularProgressIndicator(),
              SizedBox(height: MediaQuery.of(context).size.height *0.05),
                 Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    'assets/images/fingerprint.png',
                    width: MediaQuery.of(context).size.width,
                     height: MediaQuery.of(context).size.height * 0.50,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).size.height *0.10),
             creationInProgress?
             const CircularProgressIndicator():
             CustomElevatedButton(
                onPressed: () async {
                  if(buttonText=='Démarrer'||buttonText=='Reessayer')

                  {

                  setState(() {
                  enrollmentInProgress=true;
                  started=true;
                  buttonText='Annuler';
                  });

                fingerprintId=  await enrolFingerprint();
                  log.d('The fingerprint id is :'
                      ' $fingerprintId');
                  widget.employee.fingerprintId=fingerprintId;

                  setState(() {
                  enrollmentInProgress=false;
                  started=false;

                  });
                  if(fingerprintId==null)
                  {
                    setState(() {
                      buttonText='Reessayer';
                    });
                  }

                if(fingerprintId!=null) {

                  updateMessage("Enregistrement en cours",val: false,
                      colorCode: 4);

                  setState(() {
                    creationInProgress=true;
                  });

                  //complete the employee registration
                  widget.employee.fingerprintId=fingerprintId;


                  log.d('-----The fingerprint id is :'
                      ' ${widget.employee.fingerprintId}');

                  if(
                  // true
                  await EmployeeDB().create(widget.employee)
                  )
                  {


                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Employé enregistré avec succès"),
                      duration: Duration(seconds: 3),
                    ));
                  }
                  setState(() {
                    creationInProgress=false;
                  });

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RegisterEmployee()));

                }

                  }
                  else if(buttonText=='Annuler'){

                    cancelled=true;
                    await ESP32().sendData('annuler');

                    setState(() {
                      buttonText='Reessayer';
                      // creationInProgress=false;
                    });



                  }

                },
                text:
                widget.employee.fingerprintId==null? buttonText:'Achever',
              ),
            ],
          ),

        )
    );
  }

  void updateMessage(String message,{bool val=true,int colorCode=3}){
    setState(() {
      this.message = message;
      this.colorCode=colorCode;
      enrollmentInProgress=val;

    });
  }



  Future<int> getData(int val) async {
    int data = val;
    int cpt = 0;

    Future<int> fetchData() async {
      data = await ESP32().receiveData();
      if (cpt == 10 ||( data != val && data!=-1)) {
        log.d('Condition satisfied');
        return data;
      } else {
        if(cancelled) return -1000;
        cpt++;
        await Future.delayed(const Duration(seconds: 1));
        return await fetchData();
      }
    }

    return await fetchData();
  }


  Future<int?> enrolFingerprint() async {

int? fingerprintId;
    String networkConnectionError= "Vérifiez votre connexion internet et reessayez";
    String espConnectionError =
        "Vérifiez la configuration du microcontrôleur et ressayez";

    if ( !await utils.netWorkAvailable()) {
      updateMessage(networkConnectionError);
      return null;
    }

updateMessage('Vérification de la configuration du microcontrôleur',
colorCode: 4);

    if (!(await ESP32().sendData('enroll'))){

      updateMessage(espConnectionError);
      return null;
    }

    updateMessage("Placez votre doigt sur le capteur",val: false,
    colorCode: 5);


    int  data=await getData(150);

    log.d('Merveil bandit: $data');

    if(data==150) {

      updateMessage("Aucun doigt détecté");
      ESP32().sendData('enroll');
      return null;
    }

if(data==noInternetConnection) {
  updateMessage(networkConnectionError);
  return null;
}

    if(data==espConnectionFailed) {
      updateMessage(espConnectionError);
      return null;
    }
if(data==-1000) {
  updateMessage('Opération annulée',colorCode: 1);
  cancelled=false;
  return null;
}


updateMessage("Vérification de l'existence de votre empreinte en cours!",
colorCode: 4);


    if(minFingerprintId<=data&&data<=maxFingerprintId)//alredy exists
        {
      updateMessage("Une empreinte correspondante a été "
          "déjà enregistrée au sein du capteur");
      return null;

    }

log.d('Merveil le Cornard****');
    if( data==noMatchingFingerprint)//save 151
        {
      await ESP32().sendData('go');

      updateMessage("Retirez votre doigt du capteur",val: false,
      colorCode: 5);

      data = await getData(151);
      log.d('Data merv $data ');
      // log.d('Merveil salot:$data');
      if(data==151){
        updateMessage("Doigt non retiré! Veuillez reprendre",val: false);
        ESP32().sendData('enroll');
        return null;
      }


      updateMessage("L'enregistrement peut démarrer à présent! "
          "Placez à nouveau votre doigt!",val: false,
      colorCode: 4);



  data = await getData(254);
  log.d('Merveil salot:$data');
      //merveil bandit

      if (data == 254) {
        updateMessage("Aucun doigt détecté! Echec de l'enregistrement");
        ESP32().sendData('enroll');
        return null;
      }




      if (data == -15) {
        updateMessage("Retirez votre doigt du capteur pour passer "
            "à la vérification "
            "de la correspondance",val: false,
        colorCode: 4);

        data = await getData(-15);
        log.d('Data1222:hhh $data ');

        if (minFingerprintId <= data && data <= maxFingerprintId) //saved
            {


          log.d('merveil bandit:');
          updateMessage("Placez à nouveau votre doigt"
              " pour la vérification de correspondance",val: false,
          colorCode: 4);


          int x = await getData(data);

          log.d('ezechiel bandit: $x');

          if (x == noMatchingFingerprint) {
            updateMessage(
                "Empreintes non correspondantes! Echec de l'enregistrement");

          }


          if (x == noInternetConnection) {
            updateMessage(networkConnectionError);
          }

          if (x == espConnectionFailed) {
            updateMessage("$espConnectionError! Echec de l'enregistrement");
          }


          if (x == 255) {
            log.d('The data is:$x');
            fingerprintId = data;
            setState(() {

            });
            updateMessage("Enregistrement terminé!"
                " Vous pouvez retirer votre doigt du capteur",
            colorCode: 1);

            ESP32().sendData('-1');


            return fingerprintId;
          }

          if(x==data){
            updateMessage("Aucun doigt détecté! Echec de l'enregistrement");
            ESP32().sendData('enroll');
          }


        }

        else if (data == -15) {
          updateMessage("Doigt non retiré. Veillez reprendre");
          ESP32().sendData('enroll');

          return null;
        }


        if (data == espConnectionFailed) {
          updateMessage(espConnectionError);
          return null;
        }
      }
    }
return fingerprintId;
  }

}
