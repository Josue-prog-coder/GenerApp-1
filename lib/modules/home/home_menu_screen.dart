// Archivo: /lib/modules/home/home_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/modules/attendance/attendance_module_screen.dart';
import 'package:ihc_project/modules/logistics/logistics_screen.dart';
import 'package:ihc_project/providers/auth_provider.dart'; // <-- Import necesario
import 'package:ihc_project/modules/authentication/login_screen.dart'; // <-- Import para navegación
import 'package:provider/provider.dart'; // <-- Import necesario


class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  // Función de logout
  void _logout(BuildContext context) {
    // 1. Llamar a la función de logout
    Provider.of<AuthProvider>(context, listen: false).logout();

    // 2. Navegar de vuelta a la pantalla de Login y eliminar todas las rutas anteriores
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el rol actual para mostrarlo en el Drawer (o AppBar)
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentRole;
    final roleText = userRole == UserRole.coordinador ? 'Coordinador' : 'Staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('GenerApp', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
        // Agregamos el logo y el botón de cerrar sesión
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                // 1. Mostrar el Rol del Usuario
                Text(
                  roleText,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                // 2. Botón de Cerrar Sesión
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Cerrar Sesión',
                  onPressed: () => _logout(context), // <--- CERRAR SESIÓN
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Menú de Módulos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            MenuCard(
              title: 'Módulo de Asistencia',
              icon: Icons.assignment_ind_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendanceModuleScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            MenuCard(
              title: 'Módulo de Finanzas',
              icon: Icons.attach_money_outlined,
              onTap: () {
                // Lógica de navegación para el módulo de Finanzas
              },
            ),
            const SizedBox(height: 16),
            MenuCard(
              title: 'Módulo de Logística',
              icon: Icons.schedule, // Ícono de Logística
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogisticsScreen()), // Navega a la pantalla de Logística
                );
              },
            ),
            const SizedBox(height: 16),
            MenuCard(
              title: 'Módulo de Temas y Dinámicas',
              icon: Icons.book_outlined,
              onTap: () {
                // Lógica de navegación para el módulo de Temas
              },
            ),
          ],
        ),
      ),
    );
  }
}

// La clase MenuCard se mantiene igual

class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.red),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}