import 'dart:core';

/*void main() {
  Admin admin = Admin(
      firstname: 'Ezéchiel',
      lastname: 'ADEDE',
      email: 'email',
      password: 'password');

  print(admin.isSuper);
}*/

class Admin {
  String firstname;
  String lastname;
  String email;
  String password;
  String id;
  bool isSuper;

  Admin(
      {this.id = '',
      required this.firstname,
      required this.lastname,
      required this.email,
       this.password='',
      this.isSuper = false});

  Map<String, dynamic> toMap() => {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'is_super': isSuper
      };

  static Admin fromMap(Map<String, dynamic> map) {
    return Admin(
        isSuper: map['is_super'],
        id: map['id'],
        firstname: map['firstname'],
        lastname: map['lastname'],
        email: map['email'],
        //password: map['password']
    );
  }
}
