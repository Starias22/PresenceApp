import 'package:presence_app/backend/models/admin.dart';
import 'package:presence_app/backend/new_back/firestore/admin_db.dart';
import 'package:presence_app/backend/services/admin_manager.dart';
import 'package:presence_app/utils.dart';

class LoginController {
  static Future<int> login(String email, String password) async {
    Admin admin = Admin.target(email);

    return await AdminManager().signIn(admin, password);
  }

  static Future<bool> forgottenPassword(String email) async {
    return await AdminDB().exists(email);
   
  }
}
