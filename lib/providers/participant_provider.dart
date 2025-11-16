// Archivo: /lib/providers/participant_provider.dart

import 'package:flutter/material.dart';

class Participant {
  final String name;
  final String phone;
  final bool isLeader;
  final bool isAmbassador;

  Participant({
    required this.name,
    required this.phone,
    this.isLeader = false,
    this.isAmbassador = false,
  });

  Participant copyWith({
    String? name,
    String? phone,
    bool? isLeader,
    bool? isAmbassador,
  }) {
    return Participant(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isLeader: isLeader ?? this.isLeader,
      isAmbassador: isAmbassador ?? this.isAmbassador,
    );
  }
}

class ParticipantProvider extends ChangeNotifier {
  final List<Participant> _allParticipants = [
    Participant(name: 'Josué Isaías Gutiérrez Ibarra', phone: '8181818181', isLeader: false, isAmbassador: true),
    Participant(name: 'Jesús Adrián Yeverino Rodríguez', phone: '8181818181', isLeader: true, isAmbassador: false),
    Participant(name: 'Emiliano Valero Aguilar', phone: '8181818181', isLeader: false, isAmbassador: false),
    Participant(name: 'Ilse Madai Rodríguez Pérez', phone: '8181818181', isLeader: false, isAmbassador: false),
    Participant(name: 'Alfonso Alejandro Virgen Delgado', phone: '8181818181', isLeader: false, isAmbassador: true),
    Participant(name: 'Enrique Vizueth Casas', phone: '8181818181', isLeader: false, isAmbassador: false),
    Participant(name: 'Rut Calderón Ramírez', phone: '8181818181', isLeader: true, isAmbassador: false),
  ];
  
  // Variables de búsqueda separadas para Lista y Asistencia
  String _listSearchQuery = '';
  String _attendanceSearchQuery = '';

  // Método para actualizar la búsqueda de la Lista (limpia el filtro de Asistencia)
  void setListSearchQuery(String query) {
    _listSearchQuery = query;
    _attendanceSearchQuery = ''; 
    notifyListeners();
  }
  
  // Método para actualizar la búsqueda de Asistencia (limpia el filtro de Lista)
  void setAttendanceSearchQuery(String query) {
    _attendanceSearchQuery = query;
    _listSearchQuery = ''; 
    notifyListeners();
  }

  // Getter que aplica el filtro solo al query activo
  List<Participant> get participants {
    // Determina qué filtro está activo (el que no está vacío)
    final activeQuery = _listSearchQuery.isNotEmpty 
                        ? _listSearchQuery.toLowerCase() 
                        : _attendanceSearchQuery.toLowerCase();

    if (activeQuery.isEmpty) {
      return _allParticipants;
    }
    
    // Filtra la lista según el query activo
    return _allParticipants.where((p) {
      final nameMatches = p.name.toLowerCase().contains(activeQuery);
      final phoneMatches = p.phone.contains(activeQuery);
      return nameMatches || phoneMatches;
    }).toList();
  }
  
  // Métodos de gestión (add y update)
  void addParticipant(Participant participant) {
    // MODIFICACIÓN: Insertamos al inicio (índice 0) para que sea el primero en la lista
    _allParticipants.insert(0, participant);
    notifyListeners();
  }

  void updateParticipant(int index, Participant newParticipant) {
    _allParticipants[index] = newParticipant;
    notifyListeners();
  }

// FUNCIÓN DE ELIMINACIÓN
  void deleteParticipant(int index) {
    if (index >= 0 && index < _allParticipants.length) {
      _allParticipants.removeAt(index);
      notifyListeners();
    }
  }

    // Método para limpiar TODOS los filtros de búsqueda
  void clearSearchQueries() {
    _listSearchQuery = '';
    _attendanceSearchQuery = '';
    notifyListeners();
  }
  
    // Getter para el conteo total (se actualizará cuando se agregue o elimine un participante)
  int get totalParticipants => _allParticipants.length;
}