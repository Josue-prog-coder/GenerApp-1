// Archivo: /lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { coordinador, staff, none }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRole _currentRole = UserRole.none; 
  String _currentUsername = '';

  UserRole get currentRole => _currentRole;
  String get currentUsername => _currentUsername;
  bool get isAuthenticated => _currentRole != UserRole.none;
  bool get isCoordinator => _currentRole == UserRole.coordinador;
  bool get isStaff => _currentRole == UserRole.staff;

  // Método de inicio de sesión conectado a Firebase
  Future<String?> login(String username, String password, UserRole intendedRole) async {
    try {
      // Firebase Auth requiere un formato de correo electrónico.
      // Le agregamos un dominio ficticio al "username" ingresado para que funcione en Firebase sin cambiar la UI.
      String email = username.contains('@') ? username : '$username@generapp.com';

      // 1. Iniciar sesión en Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Obtener el documento del usuario desde Firestore para verificar su rol real
        DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

        if (userDoc.exists) {
          String firestoreRole = userDoc.get('rol') ?? '';

          // Convertimos el rol de la base de datos al Enum de la app
          UserRole actualRole = firestoreRole == 'Coordinador' ? UserRole.coordinador : UserRole.staff;

          // 3. Verificar que el rol en la base de datos coincida con el botón seleccionado en la UI
          if (actualRole != intendedRole) {
            await _auth.signOut(); // Cerramos sesión por seguridad si miente en su rol
            return 'Error: Rol incorrecto para este usuario.';
          }

          // 4. Asignar rol y nombre, y notificar a la interfaz
          _currentRole = actualRole;
          _currentUsername = userDoc.get('nombre') ?? username;
          notifyListeners();
          
          return null; // Retorna null indicando que hubo Éxito
        } else {
          await _auth.signOut();
          return 'Error: Tu usuario no tiene un rol asignado en la base de datos.';
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos de Firebase
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Usuario o contraseña incorrectos.';
      }
      return 'Error de autenticación: ${e.message}';
    } catch (e) {
      return 'Error inesperado: $e';
    }
    return 'Fallo desconocido al iniciar sesión.';
  }

  // Cierre de sesión
  Future<void> logout() async {
    await _auth.signOut();
    _currentRole = UserRole.none;
    _currentUsername = '';
    notifyListeners();
  }
}