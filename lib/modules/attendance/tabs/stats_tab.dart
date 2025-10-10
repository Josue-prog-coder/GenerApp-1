// Archivo: /lib/modules/attendance/tabs/stats_tab.dart (VERSIÓN FUNCIONAL Y FINAL SIN BARRA)

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/participant_provider.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:provider/provider.dart';

// Constante para la ruta del logo de estadísticas
const String kStatsLogoPath = 'lib/assets/images/logo2.png';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  // Widget auxiliar para las filas de resumen
  Widget _buildSummaryRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar al ParticipantProvider aquí (para el total)
    final participantProvider = Provider.of<ParticipantProvider>(context);
    final totalParticipants = participantProvider.totalParticipants;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      // ENVOLVEMOS LA PARTE DINÁMICA CON UN CONSUMER
      child: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          // Obtener datos que cambian (días y conteos de asistencia)
          final allDays = attendanceProvider.days;

          return Column(
            children: [
              // --- Resumen General (Tarjeta) ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Resumen General',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Total de Participantes
                      _buildSummaryRow(
                        title: 'Total de Participantes:',
                        value: totalParticipants.toString(),
                      ),

                      // Asistencia por Día
                      ...allDays.map((day) {
                        final attendanceCount = attendanceProvider.getAttendanceCountForDay(day);
                        return _buildSummaryRow(
                          title: 'Asistencia $day:',
                          value: attendanceCount.toString(),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Logo (Ícono de Reloj)
              Image.asset(
                kStatsLogoPath,
                height: 120,
                color: const Color(0xFFC62828), 
              ),
            ],
          );
        },
      ),
    );
  }
}