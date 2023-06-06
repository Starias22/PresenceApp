import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/presence.dart';
import 'package:presence_app/frontend/widgets/presence_details.dart';

class PresenceDetails extends StatelessWidget {
  final Presence presence;

  const PresenceDetails({Key? key, required this.presence}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presence Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PresenceCard(presence: presence),
      ),
    );
  }
}
