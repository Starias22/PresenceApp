import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:presence_app/frontend/widgets/toast.dart';
import 'package:presence_app/utils.dart';

class ImageUploads extends StatefulWidget {
  ImageUploads({Key? key}) : super(key: key);

  @override
  _ImageUploadsState createState() => _ImageUploadsState();
}

class _ImageUploadsState extends State<ImageUploads> {

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  int x= await  uploadPicture(pickedFile!);
  if(x==unsupportedFileExtension){
    ToastUtils.showToast(this.context, "Type d'image non pris en charge", 3);
  }

 else if(x==failure){
    ToastUtils.showToast(this.context, "Une erreur s'est produite", 3);
  }
 else//download file
 {
    ToastUtils.showToast(this.context, "Image mise à jour", 3);

  }


  }

  Future<int> uploadPicture(
      XFile pickedFile,
      ) async {
    var bytes=await pickedFile.readAsBytes();
    var contentType=pickedFile.mimeType;

    log.d('Content type: $contentType');
    var ext=getImageExtensionFromMimeType(contentType!);
    var fileName ='jfif.$ext';

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

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 32,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xffFDCF09),
                child: _photo != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    'URL_TO_DISPLAY_THE_UPLOADED_IMAGE',
                    width: 100,
                    height: 100,
                    fit: BoxFit.fitHeight,
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50)),
                  width: 100,
                  height: 100,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title:  const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),

              ],
            ),
          );
        });
  }
}
