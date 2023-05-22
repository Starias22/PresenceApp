import 'dart:core';
import 'package:presence_app/utils.dart';

class Admin {
  final utils = Utils();

  String _fname = "";
  String _lname = "";
  String _email = "";
  late String _password;

  Admin(String fname, String lname, String email, String password) {
    _fname = fname;
    _lname = lname;
    _email = email;
    _password = password;
  }

  Admin.target(String email) {
    _email = email;
  }

  void setFname(String fname) {
    _fname = fname; // Setter for fname
  }

  String getFname() => _fname;

  String getLname() => _lname;

  void setLname(String lname) {
    _lname = lname;
  }

  void setEmail(String email) {
    _email = email;
  }

  void setPassword(String password) {
    _password = password; // Setter for fname
  }

  String getPassword() => _password;

  String getEmail() => _email;
  bool hasValidEmail() => utils.isValidEmail(_email);
  bool hasValidFname() => utils.isValidName(_fname);
  bool hasValidLname() => utils.isValidName(_lname);
  bool hasValidPassword() => _password.length >= 6;
  int isValid() {
    if (!hasValidLname()) return invalidLname;
    if (!hasValidFname()) return invalidFname;
    if (!hasValidEmail()) return invalidEmail;
     if (!hasValidPassword()) return invalidPassword;
    return success;
  }

  Map<String, dynamic> toMap() =>
      {'firstname': _fname, 'lastname': _lname, 'email': _email};

  void logInformations() {
    log.i('Email:$_email');
    log.i('Firstname:$_fname');
    log.i('Lastname:$_lname');
  }
}
