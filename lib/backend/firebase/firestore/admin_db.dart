

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/models/utils/admin.dart';



class AdminDB {
  final CollectionReference _admin =
      FirebaseFirestore.instance.collection('admins');

  Future<bool> create(Admin admin) async {
    if (await exists(admin.email)) return false;
    _admin.add(admin.toMap());

    admin.id=(await getAdminIdByEmail(admin.email))!;
    _admin.doc(admin.id).update({'id':admin.id});
    return true;
  }

  Future<bool> exists(String email) async {
    QuerySnapshot querySnapshot =
        await _admin.where('email', isEqualTo: email).limit(1).get();


    return querySnapshot.docs.isNotEmpty;
  }

  Future<String?> getAdminIdByEmail(String email) async {
    QuerySnapshot querySnapshot = await _admin
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<Admin> getAdminById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await _admin.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;

    if (snapshot.exists) {
      // Convert the document snapshot into an Admin object
      Admin admin = Admin.fromMap(snapshot.data()!);
      admin.id = snapshot.id;
      return admin;
    } else {
      throw Exception('Admin not found');
    }
  }


  Future<List<Admin>> getAllAdmins() async {
    QuerySnapshot querySnapshot = await _admin.get();

    List<Admin> admins = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Admin.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return admins;
  }


  void delete(String id) {
    _admin.doc(id).delete();

  }


  void update(Admin admin) {
    _admin.doc(admin.id).update(admin.toMap());
  }

}
