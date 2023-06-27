import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/models/utils/company.dart';



class CompanyDB{


  final CollectionReference _company =
  FirebaseFirestore.instance.collection('companies');

  Future<bool> create(Company company) async {

    if (await exists(company.email)) return false;


    await _company.add(company.toMap());
    company.id=(await getCompanyIdByEmail(company.email))!;

    _company.doc(company.id).update({'id':company.id});




    return true;
  }

  Future<bool> exists(String email) async {
    QuerySnapshot querySnapshot =
    await _company.where('email', isEqualTo: email).limit(1).get();
    return querySnapshot.docs.isNotEmpty;
  }


  Future<String?> getCompanyIdByEmail(String email) async {
    QuerySnapshot querySnapshot = await _company
        .where('email', isEqualTo: email)
        .limit(1)
        .get();


    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<Company> getCompanyById(String id) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _company.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;
    if (snapshot.exists) {


      // Convert the document snapshot into an Admin object
      Company company = Company.fromMap(snapshot.data()!);
      company.id = snapshot.id;
      return company;
    } else {
      throw Exception('Employee not found');
    }
  }

  Future<Company> getCompanyByEmail(String email) async {

    QuerySnapshot querySnapshot = await _company
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    DocumentSnapshot<Map<String, dynamic>> snapshot =
    querySnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>;
    if (snapshot.exists) {

      Company company =Company.fromMap(snapshot.data()!);
      return company;
    } else {
      throw Exception('Company not found');
    }
  }



  Future<List<Company>> getAllCompanies() async {
    QuerySnapshot querySnapshot = await _company.get();

    List<Company> companies = querySnapshot.docs.map((DocumentSnapshot doc) {
      return Company.fromMap(doc.data() as Map<String,dynamic>);
    }).toList();

    return companies;
  }


  Future<void> delete(String id) async {
    _company.doc(id).delete();

  }


  void updatePictureDownloadUrl(String companyId,String url){
    _company.doc(companyId).update({'picture_download_url':url});

  }


  Future<void> update(Company company) async {

    _company.doc(company.id).update(company.toMap());
  }


}