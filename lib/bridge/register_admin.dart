import 'package:presence_app/backend/models/admin.dart';
import 'package:presence_app/backend/services/admin_manager.dart';
import 'package:presence_app/utils.dart';

class RegisterAdminController {
  Future<int> register(String fname, String lname, String email,
      String password, String confirm) async {
    if (password != confirm) {
      log.e('Passwords are not equal');
      return diffPass;
    }
    Admin admin = Admin(fname, lname, email, password);
    var adminManager = AdminManager();

    var create = await adminManager.create(admin);

    if (create != success) {
      log.e('An error occured during admin creation');
      return create;
    }

    adminManager.signUp(admin, password);
    log.d('Admin registered');
    return success;
  }
}
