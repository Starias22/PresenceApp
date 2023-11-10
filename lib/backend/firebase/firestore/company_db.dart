import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/backend/models/utils/company.dart';
import 'package:presence_app/utils.dart';



class CompanyDB{


 final CollectionReference _company =
  FirebaseFirestore.instance.collection('companies');

  Future<bool> create(Company company) async {
    if (await exists(company.email)) return false;
    Admin superAdmin=Admin
      (firstname: company.name, lastname: company.name,
        email: company.email,
    isSuper: true);
    var companyDescriptionReference=await
    _company.doc().collection('description').add(company.toMap());

var companyReference=companyDescriptionReference.parent;
    company.id=companyReference.parent!.id;
    companyDescriptionReference.update({'id':company.id});

    var companiesCollectionReference=companyReference.parent;
    companiesCollectionReference?.collection('admins').
    add(superAdmin.toMap());

    companiesCollectionReference?.collection('timezone_offset').
    add({'seconds':2*3600});
    companiesCollectionReference?.collection('last_update').
    add({'date':'2023-11-01'});




    return true;
  }

  Future<bool> exists(String email) async {
    var companies=await getAllCompanies();
    return companies.where((company) => company.email.compareTo(email)==0).isNotEmpty;


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
      throw Exception('Company not found');
    }
  }

  Future<Company?> getCompanyByEmail(String email) async {

    var companies=(await getAllCompanies()).
    where((company) => company.email.compareTo(email)==0);


    if (companies.isNotEmpty) {
      return companies.first;
    } else {
      throw Exception('Company not found');
    }
  }



  Future<List<String>> getAllCollectionsAtRoot() async {
    final firestore = FirebaseFirestore.instance;
    final collectionReference = firestore.collection('');

    final snapshots = await collectionReference.get();

    final collections = <String>[];
    for (final snapshot in snapshots.docs) {
      collections.add(snapshot.id);
    }

    return collections;
  }
  Future<List<Company>> getAllCompanies() async {

        QuerySnapshot querySnapshot = await _company.get();
        log.d('3333');
        log.d(querySnapshot.size);

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

     