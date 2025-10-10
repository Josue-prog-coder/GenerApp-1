// Archivo: /lib/modules/authentication/login_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/modules/home/home_menu_screen.dart';
import 'package:ihc_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  UserRole _selectedRole = UserRole.none;

  void _submitLogin(BuildContext context) {
    if (_selectedRole == UserRole.none) {
      setState(() {
        _errorMessage = 'Por favor, selecciona tu rol.';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = authProvider.login(
      _usernameController.text,
      _passwordController.text,
      _selectedRole, // Pasamos el rol seleccionado
    );

    if (error == null) {
      // Éxito: Navegar al menú principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeMenuScreen()),
      );
    } else {
      // Fallo: Mostrar mensaje de error
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GenerApp Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('lib/assets/images/logo.png', height: 80),
              const SizedBox(height: 20),
              const Text(
                'Selecciona tu Rol',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // --- BOTONES DE SELECCIÓN DE ROL ---
              _buildRoleSelectionButton('Coordinador', UserRole.coordinador),
              const SizedBox(height: 15),
              _buildRoleSelectionButton('Staff', UserRole.staff),
              const SizedBox(height: 30),

              // --- CAMPOS DE INICIO DE SESIÓN ---
              if (_selectedRole != UserRole.none) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuario (ej. ${_selectedRole == UserRole.coordinador ? 'coord1' : 'staff1'})',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña (1234)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ElevatedButton(
                  onPressed: () => _submitLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget Auxiliar para los botones de rol
  Widget _buildRoleSelectionButton(String label, UserRole role) {
    final bool isSelected = _selectedRole == role;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedRole = role;
          _errorMessage = ''; // Limpiar error al cambiar de rol
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red.shade700 : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}