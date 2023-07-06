import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/utils/presence.dart';
import 'package:presence_app/frontend/widgets/presence_details.dart';
import 'package:presence_app/utils.dart';

class PresenceDetails extends StatelessWidget {


  final Presence presence;
  final String nEntryTime;
  final String nExitTime;
  final bool isAdmin;



  const PresenceDetails({Key? key,
    required this.presence,
    required this.nEntryTime,
    required this.nExitTime,
    this.isAdmin=true

  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text('Détails de présence '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PresenceCard(
          isAdmin: isAdmin,
          presence: presence,
          nEntryTime: nEntryTime,
          nExitTime: nExitTime,
        ),
      ),
    );
  }
}
