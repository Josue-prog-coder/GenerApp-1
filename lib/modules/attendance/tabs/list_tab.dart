// Archivo: /lib/modules/attendance/tabs/list_tab.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/modules/attendance/add_participant_screen.dart';
import 'package:ihc_project/shared/widgets/add_participant_dialog.dart';
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/shared/widgets/list_participant_card.dart';
import 'package:ihc_project/providers/auth_provider.dart';
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

    if (result != null && result is Map<String, dynamic>) {
      final String name = result['name']!;
      
      final newParticipant = Participant(
        name: name,
        phone: result['phone']!,
        isLeader: false,
        isAmbassador: false,
      );
      // El Provider lo agrega al inicio
      participantProvider.addParticipant(newParticipant);
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Participante "$name" agregado con éxito.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    // 💡 CAMBIO: Usamos 'canManage' para incluir a Staff y Coordinador
    final bool canManage = authProvider.isAuthenticated; 
    final participants = participantProvider.participants;

    void showAccessDenied() {
      // 💡 CAMBIO: Este mensaje ya no es necesario si 'canManage' cubre a ambos roles
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso denegado. Por favor, inicia sesión con un rol autorizado.')),
      );
    }

    return CustomScrollView( 
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
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
                // 💡 Aplicamos la condición 'canManage'
                if (canManage)
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
                if (canManage) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // --- Lista de Participantes (SliverList) ---
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final participant = participants[index];
              
              // Los callbacks se asignan si 'canManage' es true.
              return ListParticipantCard(
                name: participant.name,
                phone: participant.phone,
                isLeader: participant.isLeader,
                isAmbassador: participant.isAmbassador,
                
                // LÓGICA DE EDICIÓN DE DATOS (Botón Lápiz)
                onEdit: canManage ? () async {
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
                    final Participant result = updatedParticipant as Participant;
                    
                    final finalParticipant = participant.copyWith(
                      name: result.name, 
                      phone: result.phone,
                      isLeader: participant.isLeader, 
                      isAmbassador: participant.isAmbassador, 
                    );
                    
                    participantProvider.updateParticipant(index, finalParticipant);
                  }
                } : null,
                
                // Lógica de Toggle de Rol (Solo si es 'canManage')
                onToggleLeader: canManage ? () {
                  final updatedParticipant = participant.copyWith(
                    isLeader: !participant.isLeader,
                  );
                  participantProvider.updateParticipant(index, updatedParticipant);
                } : null, // Si no puede gestionar, el botón no hace nada.

                onToggleAmbassador: canManage ? () {
                  final updatedParticipant = participant.copyWith(
                    isAmbassador: !participant.isAmbassador,
                  );
                  participantProvider.updateParticipant(index, updatedParticipant);
                } : null, // Si no puede gestionar, el botón no hace nada.
                
                // IMPLEMENTACIÓN DE ELIMINAR (Botón Basura)
                onDelete: canManage ? () {
                  // Mostrar un diálogo de confirmación antes de eliminar
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.red)),
                        content: Text('¿Estás seguro de que quieres eliminar a "${participant.name}"? Se perderán sus datos y su historial de asistencia.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              // 1. Eliminar del Provider
                              participantProvider.deleteParticipant(index);
                              // 2. Cerrar el diálogo
                              Navigator.of(dialogContext).pop();
                              // 3. Mostrar un SnackBar de éxito
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🗑️ Participante "${participant.name}" eliminado con éxito.'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                } : null,
              );
            },
            childCount: participants.length,
          ),
        ),
      ],
    );
  }
}