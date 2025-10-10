// Archivo: /lib/providers/auth_provider.dart

import 'package:flutter/material.dart';

enum UserRole { coordinador, staff, none }

class AuthProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.none; 
  String _currentUsername = '';

  UserRole get currentRole => _currentRole;
  String get currentUsername => _currentUsername;
  bool get isAuthenticated => _currentRole != UserRole.none;
  bool get isCoordinator => _currentRole == UserRole.coordinador;
  bool get isStaff => _currentRole == UserRole.staff;

  // MOCK DATA: Usuarios preestablecidos para la simulación
  final Map<String, String> _users = const {
    'coord1': '1234',
    'coord2': '1234',
    'staff1': '1234',
    'staff2': '1234',
  };

  // Método de simulación de inicio de sesión
  // Ahora también espera el rol que el usuario dice ser.
  String? login(String username, String password, UserRole intendedRole) {
    if (_users.containsKey(username) && _users[username] == password) {
      
      // 1. Verificar que el rol intentado coincida con el patrón del usuario
      bool isCoordUser = username.startsWith('coord');
      bool isStaffUser = username.startsWith('staff');

      if ((intendedRole == UserRole.coordinador && !isCoordUser) || 
          (intendedRole == UserRole.staff && !isStaffUser)) {
        return 'Error: Rol incorrecto para este usuario.';
      }

      // 2. Asignar rol y guardar usuario
      _currentRole = intendedRole;
      _currentUsername = username;
      notifyListeners();
      return null; // Éxito
    } else {
      return 'Usuario o contraseña incorrectos.'; // Fallo
    }
  }

  void logout() {
    _currentRole = UserRole.none;
    _currentUsername = '';
    notifyListeners();
  }
}