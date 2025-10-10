// Archivo: /lib/modules/attendance/attendance_list_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/shared/widgets/attendance_card.dart';
import 'package:provider/provider.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);
    final participants = participantProvider.participants;

    return ListView.builder(
      primary: false,
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return AttendanceCard(
          name: participant.name,
          phone: participant.phone,
          onPresentPressed: () {
            // Lógica para marcar como presente (aún por implementar)
            print('${participant.name} marcado como presente');
          },
          onAbsentPressed: () {
            // Lógica para marcar como ausente (aún por implementar)
            print('${participant.name} marcado como ausente');
          },
        );
      },
    );
  }
}