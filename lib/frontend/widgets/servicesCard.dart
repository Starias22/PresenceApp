

import 'package:flutter/material.dart';
import 'package:presence_app/backend/firebase/firestore/service_db.dart';
import 'package:presence_app/backend/models/utils/service.dart';
import 'package:presence_app/frontend/services.dart';
import 'package:presence_app/frontend/screens/pageServices.dart';
import 'package:presence_app/frontend/widgets/toast.dart';

class ServicesCard extends StatelessWidget {
  final Service service;
  ServicesCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool clicked=false;
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [

            Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),

                          DropdownButtonHideUnderline(
                              child: DropdownButton(

                                onChanged: (String? v){
                                  if(v == "modifier"){
                                    showServiceDialogModifier(context, service);
                                  }
                                  else if(v == "supprimer"){

                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                          title: const Text('Voulez-vous vraiment supprimer ?'),
                                          actions: [

                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color.fromARGB(
                                                        255, 10, 184, 39),
                                                    shape: const StadiumBorder(),
                                                    padding: const EdgeInsets.all(8.0)),
                                                child: const Text("Annuler")),
                                            ElevatedButton(
                                                onPressed: () async {

                                                    if(clicked) return;
                                                    clicked=true;
                                                  String? serviceId=await ServiceDB().
                                                  getServiceIdByName(service.name);
                                                 var deleted= await ServiceDB().delete(serviceId!);
                                                 String message;
                                                 if(deleted){
                                                   message="Service supprimé avec succès";
                                                 }
                                                 else{
                                                   message="Ce service est abrité par au moins un employé et ne peut donc pas être supprimé";
                                                 }

                                                  Navigator.pop(context);
                                                  ToastUtils.showToast(context, message, 3);

                                                 if(deleted){

                                                   Navigator.pushReplacement(context,
                                                       MaterialPageRoute(builder: (context) =>const LesServices()));
                                                 }

                                                },
                                                style: ElevatedButton.styleFrom(

                                                    backgroundColor: const Color.fromARGB(
                                                        255, 184, 50, 10),
                                                    shape: const StadiumBorder(),
                                                    padding: const EdgeInsets.all(8.0)),
                                                child: const Text("Supprimer")),
                                          ],
                                        )).then((value) {

                                    });
                                  }

                                },
                                items:
                                const [

                                DropdownMenuItem(

                                  value: 'modifier',
                                  child: Row(
                                    children: [
                                      Text('Modifier', style: TextStyle(color: Colors.black),),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'supprimer',
                                  child: Row(
                                    children: [
                                      Text('Supprimer', style: TextStyle(color: Colors.black),),
                                    ],
                                  ),
                                )
                              ],

                                icon: const Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Icon(Icons.more_vert, size: 25,),
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
