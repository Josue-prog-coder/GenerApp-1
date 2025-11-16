// Archivo: /lib/providers/attendance_provider.dart

import 'package:flutter/material.dart';

class AttendanceProvider extends ChangeNotifier {
  // Lista de días que se guarda de forma global
  // MODIFICACIÓN: Inicializamos con los tres días predefinidos.
  final List<String> _days = ['Día 1', 'Día 2', 'Día 3'];

  // Mapa para guardar la asistencia por día y por participante
  final Map<String, Map<String, bool?>> _attendanceData = {};

  List<String> get days => _days;

  // Método para añadir un nuevo día
  // MODIFICACIÓN: La lógica de `addDay` es ahora más sencilla: añade el siguiente día consecutivo.
  void addDay(String newDay) {
    // Si la lista ya contiene el nuevo día, simplemente salimos.
    // Aunque la lógica del selector en la UI garantiza que solo se llamará cuando se necesite un nuevo día.
    if (!_days.contains(newDay)) {
      _days.add(newDay);
      notifyListeners();
    }
  }

  // Método para obtener el estado de asistencia de un participante para un día específico
  bool? getAttendanceStatus(String day, String participantName) {
    if (!_attendanceData.containsKey(day)) {
      _attendanceData[day] = {};
    }
    return _attendanceData[day]![participantName];
  }

  // Método para actualizar el estado de asistencia de un participante
  void setAttendanceStatus(String day, String participantName, bool? isPresent) {
    if (!_attendanceData.containsKey(day)) {
      _attendanceData[day] = {};
    }
    _attendanceData[day]![participantName] = isPresent;
    notifyListeners();
  }
  
  // =======================================================
  // === LÓGICA DE ESTADÍSTICAS ===
  // =======================================================
  
  // Método para calcular la asistencia de un día específico
  int getAttendanceCountForDay(String day) {
    if (!_attendanceData.containsKey(day)) {
      return 0;
    }
    // Contamos cuántos participantes tienen el estado 'true' (Presente) para ese día
    return _attendanceData[day]!.values.where((status) => status == true).length;
  }
}