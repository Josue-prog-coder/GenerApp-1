// Archivo: /lib/shared/widgets/list_participant_card.dart

import 'package:flutter/material.dart';

class ListParticipantCard extends StatelessWidget {
  final String name;
  final String phone;
  final bool isLeader;
  final bool isAmbassador;
  final VoidCallback? onEdit;          // Botón de Lápiz
  final VoidCallback? onToggleLeader;
  final VoidCallback? onToggleAmbassador;
  final VoidCallback? onDelete;        // Botón de Basura (Eliminar)

  const ListParticipantCard({
    super.key,
    required this.name,
    required this.phone,
    this.isLeader = false,
    this.isAmbassador = false,
    this.onEdit,
    this.onToggleLeader,
    this.onToggleAmbassador,
    this.onDelete,
  });

  // Widget auxiliar para construir los botones de rol pequeños
  Widget _buildRoleButton({
    required String label,
    required bool isSelected,
    required Color activeColor, // El color base (ej: amarillo o gris)
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final bool isDisabled = onPressed == null;
    
    // 💡 LÓGICA DE COLORES CORREGIDA:
    // Tono claro para el fondo cuando está activo (tenue)
    final Color lightActiveColor = activeColor.withOpacity(0.2); 
    // Tono fuerte para el borde/icono cuando está activo
    final Color strongActiveColor = activeColor.withOpacity(0.8); 
    
    // Fondo: lightActiveColor si está seleccionado, BLANCO si no
    final Color buttonColor = isSelected && !isDisabled ? lightActiveColor : Colors.white;
    // Borde: strongActiveColor si está seleccionado, GRIS SUAVE si no
    final Color borderColor = isSelected && !isDisabled ? strongActiveColor : Colors.grey.shade300;
    // Icono y Texto: strongActiveColor si está seleccionado, GRIS SUAVE si no
    final Color contentColor = isSelected && !isDisabled ? strongActiveColor : Colors.grey.shade600;

    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      // Usamos contentColor para el icono y el texto
      icon: Icon(icon, size: 14, color: contentColor), 
      label: Text(label, style: TextStyle(fontSize: 12, color: contentColor)),
      style: OutlinedButton.styleFrom(
        backgroundColor: buttonColor,
        side: BorderSide(color: borderColor, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: isSelected && !isDisabled ? 1 : 0, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definición de colores base:
    const Color destacadoColor = Color(0xFFFFA000); // Amarillo Anaranjado
    const Color embajadorColor = Color(0xFF757575); // Gris/Plateado

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Nombre y Teléfono
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
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
                    ],
                  ),
                ),

                // Controles de Acción (Lápiz y Basura)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Ícono de Edición (Lápiz)
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                        onPressed: onEdit,
                      ),

                    // 2. Ícono de Eliminar (Basura)
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: onDelete, 
                      ),
                  ],
                ),
              ],
            ),

            // FILA DE BOTONES DE ROL
            const SizedBox(height: 12),
            Row(
              children: [
                // Botón LÍDER DESTACADO (Amarillo Tenué)
                _buildRoleButton(
                  label: 'Destacado',
                  isSelected: isLeader,
                  activeColor: destacadoColor, 
                  icon: Icons.star,
                  onPressed: onToggleLeader,
                ),
                const SizedBox(width: 10),
                // Botón EMBAJADOR GENEROSO (Plateado Tenué)
                _buildRoleButton(
                  label: 'Embajador',
                  isSelected: isAmbassador,
                  activeColor: embajadorColor, 
                  icon: Icons.military_tech,
                  onPressed: onToggleAmbassador,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}