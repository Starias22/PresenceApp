import 'package:flutter/material.dart';
import 'package:presence_app/backend/models/employee.dart';
import 'package:presence_app/backend/models/presence.dart';
import 'package:presence_app/utils.dart';


class PresenceCard extends StatelessWidget {
  final Presence presence;
  final DateTime nEntryTime;
  final DateTime nExitTime;

  const PresenceCard({Key? key, required this.presence,
    required this.nEntryTime,required this.nExitTime}) : super(key: key);


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
              'Date: ${utils.formatDateTime(presence.date)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Heure d'entrée:  ${utils.formatTime(presence.entryTime!)} "),
            Text('Heure de sortie: ${presence.exitTime==null?'Non marquée':utils.formatTime(presence.exitTime!)}'),
            Text('En ${presence.status==EStatus.present?'avance ':'retard'} de ${utils.abs(nEntryTime, presence.entryTime!)}'),
            if (presence.exitTime!=null)
              Text("Sorti ${utils.abs(nExitTime, presence.exitTime!)} "
                  "${nExitTime.isBefore(presence.exitTime!)?'après':'avant'} l'heure de sortie officielle"),
            const SizedBox(height: 8),
            Text(
              'Statut: ${utils.str(presence.status)}',
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
