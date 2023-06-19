// ignore_for_file: use_build_context_synchronously
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presence_app/backend/models/employee.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';


class CompteCard extends StatelessWidget {
  Employee employee;
   CompteCard({Key? key, required this.employee}) : super(key: key);
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  // File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    int x= await  uploadPicture(pickedFile!);
    if(x==unsupportedFileExtension){
      ToastUtils.showToast(context, "Type d'image non pris en charge", 3);
    }

    else if(x==failure){
      ToastUtils.showToast(context, "Une erreur s'est produite", 3);
    }
    else//download file
        {
      ToastUtils.showToast(context, "Image mise à jour", 3);

    }


  }

  Future<int> uploadPicture(
      XFile pickedFile,
      ) async {
    var bytes=await pickedFile.readAsBytes();
    var contentType=pickedFile.mimeType;

    log.d('Content type: $contentType');
    var ext=getImageExtensionFromMimeType(contentType!);

    var fileName ='${employee.id}.$ext';

    if(ext==null) return unsupportedFileExtension;
    try {
      await FirebaseStorage.instance.ref().child(fileName).putData(bytes,
          firebase_storage.SettableMetadata(
              contentType: contentType
          ));
      return success;
    } catch (e) {
      print(e);
      return failure;
    }
  }

  String? getImageExtensionFromMimeType(String mimeType) {
    final extensions = {
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/svg+xml': 'svg',
    };
    try {
      return  extensions.entries
          .firstWhere(
            (entry) => entry.key == mimeType,
      )
          .value;
    }
    catch(e ){
      if (e is StateError) {
        return null;
      }
      return null;

    }
  }

  // Future uploadFile() async {
  //   if (_photo == null) return;
  //   final fileName = basename(_photo!.path);
  //   final destination = 'files/$fileName';
  //
  //   try {
  //     final ref = firebase_storage.FirebaseStorage.instance
  //         .ref(destination)
  //         .child('file/');
  //     await ref.putFile(_photo!);
  //   } catch (e) {
  //     print('error occurred');
  //   }
  // }


  @override
  Widget build(BuildContext context) {


    return ListView(
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 10,
                  child: Text("Compte",
                    style: TextStyle(
                        fontSize: 45
                    ),
                  ),
                ),

                SizedBox(height: 5,),

                Center(
                    child: Text("")
                    // child: Text("Mettez à jour vos informations")
                )
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.person_pin),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("Informations personnelles et de compte",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                ],
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(employee.lastname,
                            style: const TextStyle(
                                fontSize: 15
                            ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(employee.firstname,
                            style: const TextStyle(
                                fontSize: 15
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ],
              ),

              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: InkWell(
              //     child: const Row(
              //       children: [
              //
              //         Icon(Icons.perm_identity),
              //         Padding(
              //           padding: EdgeInsets.all(8.0),
              //           child: Text("Modifier le nom",
              //             style: TextStyle(
              //                 fontSize: 20,
              //                 color: Colors.blue
              //             ),),
              //         ),
              //       ],
              //     ),
              //
              //
              //     onTap: (){
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (BuildContext context) {
              //           return FormulaireModifierEmploye(employee: employee,);
              //         }),
              //       );
              //
              //     },
              //   ),
              //
              // ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  child: const Row(
                    children: [
                      Icon(Icons.photo_camera),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Modifier ma photo",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    imgFromGallery(context);

                  },
                ),
              ),



            ],

          ),


        ),

        Padding(padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.contacts),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Coordonnées",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.email),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(employee.email,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue
                        ),),
                    ),
                  ],
                ),
              ),

              /*Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(Icons.call),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(employe.email,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue
                        ),),
                    ),
                  ],
                ),
              )*/
            ],
          ),
        ),

          /*Padding(padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.security),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Mot de passe et sécurité",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.key),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Changer le mot de passe",
                            style: TfforextStyle(
                                fontSize: 20,
                                color: Colors.blue
                            ),),
                        ),
                      ],
                    ),

                    onTap: (){
                      print("On m'a appuyé");
                    },
                  ),
                )
              ],
            ),
          )*/
      ],
    );
  }
}
