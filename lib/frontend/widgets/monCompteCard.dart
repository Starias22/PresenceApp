// ignore_for_file: use_build_context_synchronously
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presence_app/backend/firebase/firestore/employee_db.dart';
import 'package:presence_app/backend/firebase/storage.dart';
import 'package:presence_app/backend/models/utils/employee.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';


class CompteCard extends StatelessWidget {
  Employee employee;
   CompteCard({Key? key, required this.employee}) : super(key: key);


  final ImagePicker _picker = ImagePicker();

  Future<void> removePictureIfExists() async {

    final pictureName =
        (await FirebaseStorage.instance.ref().listAll()).items.
        where((item) => item.name.
    startsWith(RegExp('^${employee.id}'))).toList()[0].name;
    await FirebaseStorage.instance.ref(pictureName).delete();

  }

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
      ToastUtils.showToast(context, "Photo mise à jour", 3);

    }


  }

  Future<int> uploadPicture(
      XFile pickedFile,
      ) async {
    await removePictureIfExists();
    var bytes=await pickedFile.readAsBytes();
    var contentType=pickedFile.mimeType;

    var ext=getImageExtensionFromMimeType(contentType!);

    var fileName ='${employee.id}.$ext';

    if(ext==null) return unsupportedFileExtension;
    try {
     Storage.saveFile(fileName, contentType, bytes);

      String downloadUrl=await Storage.getDownloadURL(fileName);
      EmployeeDB().updatePictureDownloadUrl(employee.id, downloadUrl);


      return success;
    } catch (e) {
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

        Padding(padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.contacts),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text("Coordonnées",
                      style: TextStyle(
                          fontSize: 10,
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
                    const Icon(Icons.email),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(employee.email,
                        style: const TextStyle(
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


      ],
    );
  }
}
