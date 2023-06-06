import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/presence.dart';

class PresenceCard extends StatelessWidget {
  final Presence presence;

  const PresenceCard({Key? key, required this.presence}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${presence.date}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
           if(presence.entryTime!=null) Text('Entry Time: ${presence.entryTime}'),
            Text('Exit Time: ${presence.exitTime}'),
            const SizedBox(height: 8),
            Text(
              'Status: ${presence.status}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
