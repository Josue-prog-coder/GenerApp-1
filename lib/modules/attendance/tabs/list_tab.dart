// Archivo: /lib/modules/attendance/tabs/list_tab.dart (CORRECCIÓN ESTRUCTURAL)

import 'package:flutter/material.dart';
import 'package:ihc_project/modules/attendance/add_participant_screen.dart';
import 'package:ihc_project/shared/widgets/add_participant_dialog.dart'; 
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/shared/widgets/list_participant_card.dart';
import 'package:provider/provider.dart';


class ListTab extends StatelessWidget {
  const ListTab({super.key});

  void _navigateToAddParticipantScreen(BuildContext context) async {
    final participantProvider = Provider.of<ParticipantProvider>(context, listen: false);

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddParticipantDialog(); 
      },
    );

    if (result != null && result is Map<String, dynamic>) { // Corregido a Map<String, dynamic>
      final newParticipant = Participant(
        name: result['name']!,
        phone: result['phone']!,
        isLeader: false,
        isAmbassador: false,
      );
      participantProvider.addParticipant(newParticipant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);
    final participants = participantProvider.participants;

    return CustomScrollView( // <-- Usamos CustomScrollView como contenedor principal
      slivers: [
        // --- Barra de búsqueda y Botón (Sliver para fluir con el scroll) ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0), // Padding Superior
            child: Column(
              children: [
                // --- Barra de búsqueda ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar participante...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      onChanged: (value) {
                        participantProvider.setListSearchQuery(value); 
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // --- Botón 'Añadir Participante' ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAddParticipantScreen(context), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
                      label: const Text(
                        'Añadir Participante',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Espacio entre botón y lista
              ],
            ),
          ),
        ),
        
        // --- Lista de Participantes (SliverList para ocupar el resto) ---
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final participant = participants[index];
              return ListParticipantCard(
                name: participant.name,
                phone: participant.phone,
                isLeader: participant.isLeader,
                isAmbassador: participant.isAmbassador,
                
                onEdit: () async {
                  final updatedParticipant = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddParticipantScreen( 
                        participantToEdit: participant,
                        index: index, 
                      ),
                    ),
                  );

                  if (updatedParticipant != null) {
                    participantProvider.updateParticipant(index, updatedParticipant as Participant);
                  }
                },
              );
            },
            childCount: participants.length,
          ),
        ),
      ],
    );
  }
}