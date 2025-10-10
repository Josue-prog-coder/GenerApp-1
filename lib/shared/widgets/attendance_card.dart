// Archivo: /lib/shared/widgets/attendance_card.dart (CÓDIGO FINAL CON BOTONES VERTICALES)

import 'package:flutter/material.dart';

class AttendanceCard extends StatelessWidget {
  final String name;
  final String phone;
  final bool? isPresent; // null, true, or false
  final VoidCallback onPresentPressed;
  final VoidCallback onAbsentPressed;

  const AttendanceCard({
    super.key,
    required this.name,
    required this.phone,
    this.isPresent,
    required this.onPresentPressed,
    required this.onAbsentPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los estilos de los botones
    final presentColor = isPresent == true ? Colors.green : Colors.white;
    final presentTextColor = isPresent == true ? Colors.white : Colors.black;
    final absentColor = isPresent == false ? Colors.red : Colors.white;
    final absentTextColor = isPresent == false ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, // Alineamos verticalmente al centro
          children: [
            // 1. Sección de Nombre y Teléfono (Usa todo el espacio necesario)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Evita que el texto se desborde
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 10), // Separación entre nombre y botones
            
            // 2. Sección de Botones (VERTICAL)
            Column(
              mainAxisSize: MainAxisSize.min, // Ocupa el mínimo espacio vertical
              children: [
                // Botón de Presente
                SizedBox(
                  width: 100, // Fijamos el ancho para consistencia
                  height: 30, // Fijamos la altura
                  child: ElevatedButton(
                    onPressed: onPresentPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: presentColor,
                      foregroundColor: presentTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.green, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      elevation: 0,
                    ),
                    child: const Text('Presente', style: TextStyle(fontSize: 12)),
                  ),
                ),
                
                const SizedBox(height: 6), // Espacio entre los botones
                
                // Botón de Ausente
                SizedBox(
                  width: 100, // Mismo ancho
                  height: 30, 
                  child: ElevatedButton(
                    onPressed: onAbsentPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: absentColor,
                      foregroundColor: absentTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      elevation: 0,
                    ),
                    child: const Text('Ausente', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}