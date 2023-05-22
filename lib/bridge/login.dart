import 'package:presence_app/backend/models/admin.dart';
import 'package:presence_app/backend/services/admin_manager.dart';
import 'package:presence_app/utils.dart';

class LoginController {
  static Future<int> login(String email, String password) async {
    Admin admin = Admin.target(email);

    return await AdminManager().signIn(admin, password);
  }

  static Future<int> forgottenPassword(String email) async {
    Admin admin = Admin.target(email);

    int val = await AdminManager().exists(admin);
    if (val == invalidEmail) {
      return val;
    }
    if (val == emailNotExists) {
      return val;
    }
    log.e('dfg');
    return await AdminManager().resetPassword(admin);
  }
}
