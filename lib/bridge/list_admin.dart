import 'package:presence_app/backend/models/admin.dart';
import 'package:presence_app/backend/services/admin_manager.dart';

class ListAdminController {
  static Future<List<Admin>> retrieveAdmins() async {
    var data = await AdminManager().getData() as Map;

    List<Admin> admins = [];
    Admin admin;
    data.forEach((key, childs) {
      admin = Admin.target(childs['email']);
      admin.setFname(childs['firstname']);
      admin.setLname(childs['lastname']);

      //AdminManager().fetch(admin);
      admins.add(admin);
    });
    return admins;
  }
}
