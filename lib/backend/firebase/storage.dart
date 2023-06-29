import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class Storage{

  static Future<String> getDownloadURL(String fileName) async {
    try {
      return await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .getDownloadURL();
    } catch (e) {
      return "";
    }
  }
  static void saveFile(String filename,String contentType,Uint8List bytes){
    FirebaseStorage.instance.ref()
        .child(filename)
        .putData(bytes,SettableMetadata(contentType: contentType));
  }

}