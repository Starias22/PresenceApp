import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/services/employee_manager.dart';
import 'package:presence_app/utils.dart';

import '../models/admin.dart';
import 'login.dart';

class AdminManager {
  late DatabaseReference _ref;
  final adm = "admin";

  AdminManager() {
    _ref = FirebaseDatabase.instance.ref('${adm}s');
  }

  Future<int> getCount() async {
    var data = await getData();
    //var x = data as Map;
    log.i('data: $data');

    return data == false ? 0 : data.length;
  }

  Future<int> getNextNum() async {
    var data = await getData();
    return utils.getNextNum(data, adm);
  }

  Future<int> create(Admin admin) async {
    int val = admin.isValid();
    log.i('val:$val');

    if (val != success) {
      log.e('Invalid admin');

      return val;
    }
    if (!admin.hasValidPassword()) {
     // log.e('Invalid password');

      return invalidPassword;
    }
    val = await exists(admin);

    if (val == emailExists) {
     // log.e('That email is already assigned to an admin');
      return emailInUse;
    }
     if (await 
   EmployeeManager().exists(Employee.target(admin.getEmail())) ==
        emailExists) {
        //log.e('That email is already assigned to an employee');

      return employeeExists;
    }

    int num = await getNextNum();
    _ref.child('$adm$num').set(admin.toMap());
    //log.d('Admin created successfully');

    return success;
  }

  Future<int> exists(Admin admin) async {
    if (!admin.hasValidEmail()) {
      //log.e('Invalid email');

      return invalidEmail;
    }
    int test = emailNotExists;
    var data = await getData();

    log.i(data);

    if (data != false) {
      (data as Map).forEach((node, chields) {
        if (chields['email'] == admin.getEmail()) {
          test = emailExists;
          log.d('Ok the admin exists');

          return;
        }
      });
    }
    return test;
  }

  Future<int> fetch(Admin admin) async {
    if (!admin.hasValidEmail()) {
      //log.e('Invalid email');

      return invalidEmail;
    }

    var data = await getData();

    //log.i('Not empty?$data');

    if (data != false) {
      (data as Map).forEach((node, childs) {
        if (childs['email'] == admin.getEmail()) {
          admin.setFname(childs['firstname']);
          admin.setLname(childs['lastname']);
          //log.d('Names retrieved');
          return;
        }
      });
    }

    return success;
  }

  Future<String> getKey(Admin admin) async {
    String k = '';

    if (await exists(admin) != emailExists) {
      return '';
    }
    Map data = await getData();

    data.forEach((key, chields) {
      if (chields['email'] == admin.getEmail()) {
       // log.d('Okay we can get the key');

        k = key;
        return;
      }
    });
    return k;
  }

  dynamic getData() async {
    DatabaseEvent event = (await _ref.orderByChild(adm).once());
    var snapshot = event.snapshot;
    if (snapshot.value == null) return false;
    try {
      return snapshot.value as Map;
    } catch (e) {
      log.e('An error occured: $e');
      return false;
    }
  }

  void clear() {
    _ref.remove();
    //log.d('All admins removed');
  }

  Future<int> delete(Admin admin) async {
    if (await exists(admin) != emailExists) {
      //log.e('Invalid email or no such admin');

      return emailNotExists;
    }
    _ref.child(await getKey(admin)).remove();
    //log.e('Admin removed successfully');

    return success;
  }

  Future<int> update(Admin admin, String newEmail) async {
    if (!utils.isValidEmail(newEmail)) {
      //log.e('Invalid email for that admin');

      return invalidEmail;
    }

    if (newEmail == admin.getEmail()) {
      //log.i('Same email provided');

      return sameEmail;
    }

    int val = await exists(admin);

    if (val != emailExists) {
      //log.e('That admin doesnt exist and then canot be modified');

      return val;
    }
    val = await exists(Admin.target(newEmail));
    if (val != emailNotExists) {
      log.e('The new email provided is already in use');

      return emailInUse;
    }

    _ref.child(await getKey(admin)).update({'email': newEmail});
    admin.setEmail(newEmail);
    //log.d('Admin email updated successsfully');

    return success;
  }

  Future<int> updateFname(Admin admin, String newFname) async {
    await fetch(admin);
    if (!utils.isValidName(newFname)) {
      log.e('Invalid firstname for that admin');

      return invalidFname;
    }

    if (newFname == admin.getFname()) {
      //log.i('Same firstname provided');

      return sameEmail;
    }

    int val = await exists(admin);

    if (val != emailExists) {
      //log.e('That admin doesnt exist and then canot be modified');

      return val;
    }

    _ref.child(await getKey(admin)).update({'firstname': newFname});
    admin.setFname(newFname);
    //log.d('Admin firstname updated successfully');

    return success;
  }

  Future<int> updateLname(Admin admin, String newLname) async {
    await fetch(admin);

    if (!utils.isValidName(newLname)) {
      log.e('Invalid lastname for that admin');

      return invalidLname;
    }

    if (newLname == admin.getLname()) {
      //log.i('Same lastname provided');

      return sameLname;
    }

    int val = await exists(admin);

    if (val != emailExists) {
      log.e('That admin doesnt exist and then canot be modified');

      return val;
    }

    _ref.child(await getKey(admin)).update({'lastname': newLname});
    admin.setFname(newLname);
    //log.d('Admin lastname updated successfully');

    return success;
  }

  Future<int> signUp(Admin admin, String password) async {
    return 0;
    //return await Login().signUp(admin.getEmail(), password);
  }

  Future<int> signIn(Admin admin, String password) async {
    admin.setPassword(password);
    if (!admin.hasValidEmail()) return invalidEmail;
    if (!admin.hasValidPassword()) return invalidPassword;
    int val = await Login().signIn(admin.getEmail(), password);

if (val == tooManyRequests) {
      resetPassword(admin);
      return val;
    }
    if (await exists(admin) == emailNotExists) {
      return emailNotExists;
    }


    
    if (val == success && await exists(admin) == emailNotExists) {
      //log.i('Your account has been deleted for you are no longer admin');
      return await _deleteCurrentUser();
    }
    //log.d('val equals:$val');
    return val;
  }

  Future<int> updateEmail(String newEmail) async {
    return await Login().updateEmailForCurrentUser(newEmail);
  }

  Future<int> updatePassword(String newPassword) async {
    return await Login().updatePasswordForCurrentUser(newPassword);
  }

  Future<int> signOut() async {
    return await Login().signOut();
  }

  Future<int> resetPassword(Admin admin) async {
    return 0;
    //return await Login().resetPassword(admin.getEmail());
  }

  Future<int> _deleteCurrentUser() async {
    return await Login().deleteCurrentUser();
  }

  void test() async {
    Admin admin = Admin('Jane', 'X', 'example@gmail.com', '');

    AdminManager am = AdminManager();
    am.clear();
    var data = await am.getData();

    log.i('Not empty ? $data'); //false

    var count = await am.getCount(); //0
    log.i('Number of available admins: $count');

    Admin wrong = Admin.target('djfj'),
        good = Admin.target('example@gmail.com');
    log.i(good.getEmail());

    int x = await am.exists(wrong);
    log.i(x); //example@gmail.com

    x = await am.exists(good);
    log.i(x); //false

    await am.fetch(good);

    log.i('fname:${good.getFname()}'); //empty
    log.i('lname:${good.getLname()}'); //empty

    log.i('key of wrong:${await am.getKey(wrong)}');
    log.i('key of good:${await am.getKey(good)}');
    int crt = await am.create(admin);
    log.i('is admin created?:$crt');

    crt = await am.create(good);
    log.i('is good created?:$crt'); //0

    var del = await am.delete(wrong);
    log.i('is wrong deleted?:$del'); //

    del = await am.delete(good);
    log.i('is good deleted?:$del'); //0

    del = await am.delete(good);
    log.i('is good deleted?:$del'); //false

    var upd = await am.update(wrong, 'new@gmail.com');
    log.i('is wrong updated?:$upd'); //false
    am.fetch(good);

    upd = await am.update(good, 'new@gmail.com');
    log.i('is good updated?:$upd'); //false there is no admin

    crt = await am.create(admin);
    log.i('is admin created?:$crt'); //0

    crt = await am.create(good);
    log.i('is good created?:$crt'); //false

    good.setEmail('admin@gmail.com');
    log.d('Call to create');
    crt = await am.create(good);
    log.i('is good created?:$crt'); //false

    good.setFname('John');
    good.setLname('Doe');

    log.d('Before call to create');
    crt = await am.create(good);
    log.d('After call to create');
    log.i('is good created?:$crt'); //0

    crt = await am.create(good);
    log.i('is good created?:$crt'); //false

    good.setFname('Oliver');
    good.setLname('Queen');
    good.setEmail('another@gmail.com');
    crt = await am.create(good);
    log.i('is good created?:$crt'); //0

    log.i('Email of wrong:${wrong.getEmail()}');
    upd = await am.update(wrong, 'new@gmail.com');
    log.i('is wrong updated?:$upd'); //false

    good.setEmail('invalidmail');
    upd = await am.update(good, 'new@gmail.com');
    log.i('is good updated?:$upd'); //false

    good.setEmail('admin@gmail.com');
    upd = await am.update(good, 'admin@gmail.com'); //same email
    log.i('is good updated?:$upd'); //false

    upd = await am.update(admin, 'adminmodified@gmail.com'); //new email exists
    log.i('is admin updated?:$upd'); //0

    log.i('email of admin: ${admin.getEmail()}'); //adminmodified@gmail.com

    admin = Admin.target(admin.getEmail());
    await am.fetch(admin);

    admin.logInformations(); // Jane X*/
  }

  void test2() async {
    AdminManager am = AdminManager();
    // await am.signOut();
    Admin admin = Admin.target('admin@gmail.com');

    // await am.signIn(admin, ''); //empty pwd

    //await am.signIn(admin, 'gjh'); //user doesn't exists

    //await am.signUp(admin, '');//empty pass
    //await am.signUp(admin, 'pass');//week pass
    //await am.signUp(admin, 'password');//ok user created
    // await am.signIn(admin, '');//empty passsword
    //await am.signIn(admin, 'passr');//wrong password
    //await am.signIn(admin, 'password'); //ok signed in

    //await am.signOut(); //ok signed out
    //await am.delete(admin);
    //await am.signIn(admin, 'password')
  }
}
