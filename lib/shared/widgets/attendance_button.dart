// Archivo: /lib/shared/widgets/attendance_button.dart

import 'package:flutter/material.dart';

class AttendanceButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap; // Añadimos la propiedad onTap

  const AttendanceButton({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap, // La hacemos requerida
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Usamos GestureDetector para detectar el tap
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}