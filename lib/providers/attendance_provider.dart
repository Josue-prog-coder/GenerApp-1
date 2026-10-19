// Archivo: /lib/providers/attendance_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- IMPORTANTE: Agregar import de Firestore

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de días que se guarda de forma global
  final List<String> _days = ['Día 1', 'Día 2', 'Día 3'];

  // Mapa para guardar la asistencia por día y por participante (Sincronizado con Firebase)
  final Map<String, Map<String, bool?>> _attendanceData = {};

  List<String> get days => _days;

  // Constructor: Escucha los cambios de Firebase en tiempo real apenas arranca la app
  AttendanceProvider() {
    _listenToAttendanceData();
  }

  void _listenToAttendanceData() {
    _firestore.collection('asistencias').snapshots().listen((snapshot) {
      // Limpiamos el mapa local para reconstruirlo con los datos más recientes de la nube
      _attendanceData.clear(); 
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final day = data['dia_sesion'] as String?;
        // NOTA: Asegúrate de pasar el ID del documento del participante desde la UI en lugar del nombre
        final participantId = data['id_participante'] as String?; 
        final isPresent = data['presente'] as bool?;

        if (day != null && participantId != null) {
          if (!_attendanceData.containsKey(day)) {
            _attendanceData[day] = {};
          }
          _attendanceData[day]![participantId] = isPresent;
        }
      }
      notifyListeners(); // Actualiza la UI automáticamente cuando alguien toma lista
    });
  }

  // Método para añadir un nuevo día
  void addDay(String newDay) {
    if (!_days.contains(newDay)) {
      _days.add(newDay);
      notifyListeners();
    }
  }

  // Método para obtener el estado de asistencia de un participante para un día específico
  bool? getAttendanceStatus(String day, String participantId) {
    if (!_attendanceData.containsKey(day)) {
      return null;
    }
    return _attendanceData[day]![participantId];
  }

  // Método para actualizar el estado de asistencia de un participante en Firebase
  Future<void> setAttendanceStatus(String day, String participantId, bool? isPresent) async {
    // 1. Actualización optimista local (para que la UI se sienta instantánea sin lag)
    if (!_attendanceData.containsKey(day)) {
      _attendanceData[day] = {};
    }
    _attendanceData[day]![participantId] = isPresent;
    notifyListeners();

    // 2. Operación en Firebase
    try {
      // Primero buscamos si ya existe un registro previo para no duplicarlo
      final query = await _firestore
          .collection('asistencias')
          .where('id_participante', isEqualTo: participantId)
          .where('dia_sesion', isEqualTo: day)
          .get();

      if (query.docs.isNotEmpty) {
        // Si existe, lo actualizamos
        await query.docs.first.reference.update({
          'presente': isPresent,
          'fecha_registro': FieldValue.serverTimestamp(),
        });
      } else {
        // Si no existe, creamos el documento nuevo
        await _firestore.collection('asistencias').add({
          'id_participante': participantId,
          'dia_sesion': day,
          'presente': isPresent,
          'fecha_registro': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Error al registrar asistencia en Firebase: $e");
    }
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