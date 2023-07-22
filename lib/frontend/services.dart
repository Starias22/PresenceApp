// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/models/utils/service.dart';
import 'package:presence_app/frontend/screens/services_management.dart';
import 'package:presence_app/frontend/widgets/custom_button.dart';
import 'package:presence_app/frontend/widgets/toast.dart';

void showServiceDialog(BuildContext context) async {
  bool createClicked=false;


  String serviceName = "";
  final key = GlobalKey<FormState>();

  showDialog(context: context, builder: (BuildContext context){

    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                  key: key,
                  child: TextFormField(
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => serviceName = value,
                      validator: (value) =>
                      serviceName.isEmpty ?
                      "Veuillez saisir le nom du service" : null,

                      decoration: InputDecoration(
                          label: const Text('Nom du service:'),
                          hintText: "Ex: Comptabilité",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          )
                      )
                  )
              ),

              Wrap(
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text("Annuler"),
                  ),

                  const SizedBox(width: 20,),

                  CustomElevatedButton(
                    onPressed: () async {
                      if(createClicked) return;
                      createClicked=true;
                      if (key.currentState!.validate()) {
                        key.currentState!.save();

                        String message;
                        bool created=await ServiceDB().create(Service(name: serviceName));
                        if(created)
                          {
                            message="Service ajouté avec succès";
                          }
                        else{
                          message="Ce service existe déjà";
                        }
                        Navigator.pop(context);
                        ToastUtils.showToast(context, message, 3);
                        if(created){
                         Navigator.pop(context);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>const ServicesManagement()));
                        }
                      }

                    },
                    text: "Enregistrer",
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  });
}

void showServiceUpdateDialog(BuildContext context, Service service) async {
  bool updateClicked=false;
  String serviceName = "";

  final key = GlobalKey<FormState>();
  String initialServiceName=service.name;

  showDialog(context: context, builder: (BuildContext context){

    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                  key: key,
                  child: TextFormField(
                      initialValue: service.name,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value!.isEmpty ? "Veuillez saisir le nom du service" : null,
                      onSaved: (value) => serviceName = value!,

                      decoration: InputDecoration(
                          label: const Text('Nom du service:'), hintText: "Ex: Comptabilité",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.0),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.green),
                          )
                      )
                  )
              ),

              Wrap(
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text("Annuler"),
                  ),

                  const SizedBox(width: 20,),

                  CustomElevatedButton(

                    onPressed: () async {

                      if(updateClicked) return;
                      updateClicked=true;

                      if (key.currentState!.validate()) {

                        key.currentState!.save();
                        //Navigator.pop(context);



                        String message;
                        bool updated=
                        await ServiceDB().update(Service(name: initialServiceName)
                            ,Service(name: serviceName));
                        Navigator.pop(context);
                        if(updated)
                        {
                          message="Service modifié avec succès";

                        }
                        else{
                          message="Ce service existe déjà";
                        }

                      //Navigator.pop(context);
                        ToastUtils.showToast(context, message, 3);
                        if(updated){
                          //Navigator.of
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) =>const ServicesManagement()));
                        }
                      }
                    },
                    text: "Modifier",
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  });
}
