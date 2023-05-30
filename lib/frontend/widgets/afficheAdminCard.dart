import 'package:flutter/material.dart';
import 'package:presence_app/frontend/screens/afficherAdmins.dart';
import 'package:presence_app/frontend/screens/pageModifierAdmin.dart';
import 'package:presence_app/frontend/widgets/toast.dart';

import '../../new_back/firestore/admin_db.dart';
import '../../new_back/models/admin.dart';

class AfficherAdminCard extends StatelessWidget {
  final Admin admin;
   const AfficherAdminCard({Key? key, required this.admin}) : super(key: key);

 
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("tapppp");
      },
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    height: 90.0,
                    width: 90.0,
                    child: Image.asset(
                      'assets/images/imsp1.png',
                      fit: BoxFit.fill,
                    ),
                  )),
              Expanded(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                admin.lastname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                admin.firstname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                admin.email,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        DropdownButtonHideUnderline(
                            child: DropdownButton(
                          onChanged: (String? v)  {
                            if (v == "modifier") {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) {
                                  return FormulaireModifierAdmin(admin: admin);
                                }),
                              );
                            } else if (v == "supprimer") {
                              if(admin.isSuper)
                                {
                                  ToastUtils.showToast(context, 'Le super admin ne peut pas être supprimé', 3);
                                  return;
                                }

                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        actionsAlignment:
                                            MainAxisAlignment.spaceAround,
                                        title: const Text(
                                            'Voulez-vous vraiment supprimer ?'),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(
                                                      255, 10, 184, 39),
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets.all(
                                                      8.0)),
                                              child: const Text("Annuler")),
                                          ElevatedButton(
                                              onPressed: () async {
                                                String? id=await AdminDB().getAdminIdByEmail(admin.email);
                                             AdminDB().delete(id!);


                                                Navigator.of(context).pop();
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => const AfficherAdmins()));

                                                 
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color.fromARGB(
                                                      255, 184, 50, 10),
                                                  shape: const StadiumBorder(),
                                                  padding: const EdgeInsets.all(
                                                      8.0)),
                                              child: const Text("Supprimer")),
                                        ],
                                      )).then((value) {
                                //setState(() {});
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'modifier',
                              child: const Row(
                                children: [
                                  Text(
                                    'Modifier',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              onTap: () {
                               /* log.d('**********');
                                Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return FormulaireModifierAdmin(admin: admin,);
                  }));*/
                              },
                            ),
                            const DropdownMenuItem(
                              value: 'supprimer',
                              child: Row(
                                children: [
                                  Text(
                                    'Supprimer',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              
                            )
                          ],
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.more_vert,
                              size: 25,
                            ),
                          ),
                        ))
                      ],
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
