// Archivo: /lib/modules/attendance/tabs/attendance_tab.dart (CÓDIGO FINAL LIMPIO)

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:ihc_project/shared/widgets/attendance_card.dart';
import 'package:provider/provider.dart';
// import 'package:ihc_project/providers/auth_provider.dart'; // No se necesita, eliminamos la variable

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  String _selectedDay = 'Día 1';

  @override
  Widget build(BuildContext context) {
    // Conectamos a los Providers
    final participantProvider = Provider.of<ParticipantProvider>(context);
    final participants = participantProvider.participants;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    
    // LA VARIABLE 'authProvider' FUE ELIMINADA PARA QUITAR LA ALERTA.
    
    return CustomScrollView( 
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Selector de Días
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Día Actual',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedDay,
                        icon: const Icon(Icons.arrow_drop_down),
                        underline: const SizedBox(),
                        items: [
                          // Lista de días existentes
                          ...attendanceProvider.days.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          
                          // Opción 'Agregar día' (Visible para todos)
                          DropdownMenuItem<String>(
                            value: 'Agregar día',
                            child: Row(
                              children: const [
                                Icon(Icons.add, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Agregar día', style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue == 'Agregar día') {
                              // La lógica de addDay siempre se ejecuta
                              final newDayNumber = attendanceProvider.days.length + 1;
                              final newDayName = 'Día $newDayNumber';
                              attendanceProvider.addDay(newDayName);
                              _selectedDay = newDayName;
                            } else {
                              _selectedDay = newValue!;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Barra de Búsqueda
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar participante...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) {
                      participantProvider.setAttendanceSearchQuery(value); 
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // --- Lista de Participantes (SliverList) ---
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final participant = participants[index];
              final attendanceStatus = attendanceProvider.getAttendanceStatus(_selectedDay, participant.name);
              return AttendanceCard(
                name: participant.name,
                phone: participant.phone,
                isPresent: attendanceStatus,
                onPresentPressed: () => attendanceProvider.setAttendanceStatus(_selectedDay, participant.name, true),
                onAbsentPressed: () => attendanceProvider.setAttendanceStatus(_selectedDay, participant.name, false),
              );
            },
            childCount: participants.length,
          ),
        ),
      ],
    );
  }
}