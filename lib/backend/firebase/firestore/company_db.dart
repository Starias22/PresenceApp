import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:presence_app/backend/models/utils/admin.dart';
import 'package:presence_app/backend/models/utils/company.dart';
import 'package:presence_app/utils.dart';



class CompanyDB{


 final CollectionReference _company =
  FirebaseFirestore.instance.collection('companies');

  Future<bool> create(CompanyDescription company) async {//good
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

  Future<bool> exists(String email) async {//good
    var companies=await getAllCompaniesDescriptions();
    return companies.where((company) => company.email.compareTo(email)==0).isNotEmpty;


  }


  Future<String?> getCompanyIdByEmail(String email) async {//good
    
    var companies=(await getAllCompaniesDescriptions());
    var match=companies.where((company) => company.email.compareTo(email)==0).toList();
    if(match.isNotEmpty) return match[0].id;
    return null;
  }

  Future<CompanyDescription> getCompanyDescriptionById(String id) async {//ok

    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _company.doc(id).get()as DocumentSnapshot<Map<String, dynamic>>;
    if (snapshot.exists) {


      // Convert the document snapshot into an Admin object
      CompanyDescription company = CompanyDescription.fromMap(snapshot.data()!);
      company.id = snapshot.id;
      return company;
    } else {
      throw Exception('Company not found');
    }
  }

  Future<CompanyDescription?> getCompanyDescriptionByEmail(String email) async {//ok

    var companiesDescriptions=(await getAllCompaniesDescriptions()).
    where((description) => description.email.compareTo(email)==0);


    if (companiesDescriptions.isNotEmpty) {
      return companiesDescriptions.first;
    } else {
      throw Exception('Company not found');
    }
  }



  /*Future<List<String>> getAllCollectionsAtRoot() async {
    final firestore = FirebaseFirestore.instance;
    final collectionReference = firestore.collection('');

    final snapshots = await collectionReference.get();

    final collections = <String>[];
    for (final snapshot in snapshots.docs) {
      collections.add(snapshot.id);
    }

    return collections;
  }*/
  Future<List<CompanyDescription>> getAllCompaniesDescriptions() async
  {//maybe a problem

    List<CompanyDescription>  descriptions=[];

        QuerySnapshot querySnapshot = await _company.get();
        log.d(querySnapshot.size);
        CompanyDescription description;
        CollectionReference descriptionCollection;
        for (var doc in querySnapshot.docs){
          descriptionCollection= doc.reference.collection('description');
          // Get the document in the "description" collection
           var theDescriptionDoc = (await descriptionCollection.get()).docs[0];
           description= CompanyDescription(name: theDescriptionDoc['name'],
               email: theDescriptionDoc['email'],
               country: theDescriptionDoc['country'],
               city: 'city',
               subscribeStatus: theDescriptionDoc['subscribeStatus']
           );
           descriptions.add(description);

        }
        return descriptions;


  }


  Future<void> delete(String id) async {//ok
    _company.doc(id).delete();

  }


  void updatePictureDownloadUrl(String companyId,String url){//ok
    _company.doc(companyId).update({'picture_download_url':url});

  }


  Future<void> update(CompanyDescription company) async {

    _company.doc(company.id).update(company.toMap());
  }


}

     