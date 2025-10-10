// Archivo: /lib/shared/widgets/list_participant_card.dart

import 'package:flutter/material.dart';

class ListParticipantCard extends StatelessWidget {
  final String name;
  final String phone;
  final bool isLeader;
  final bool isAmbassador;
  final VoidCallback? onEdit;

  const ListParticipantCard({
    super.key,
    required this.name,
    required this.phone,
    this.isLeader = false,
    this.isAmbassador = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Borde redondeado y margen más ajustado al diseño
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1, // Sombra ligera
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sección de Nombre y Teléfono
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Para evitar que el nombre se salga
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Insignias (Estrella y Medalla)
                  Row(
                    children: [
                      // Líder Destacado (Estrella - isLeader)
                      if (isLeader) // <-- AHORA isLeader LLEVA LA ESTRELLA
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: const Icon(Icons.star, color: Colors.amber, size: 20),
                        ),
                      // Embajador Generoso (Medalla - isAmbassador)
                      if (isAmbassador) // <-- AHORA isAmbassador LLEVA LA MEDALLA
                        const Icon(Icons.military_tech, color: Colors.grey, size: 20),
                    ],
                  ),
                ],
              ),
            ),

            // Ícono de Edición
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}