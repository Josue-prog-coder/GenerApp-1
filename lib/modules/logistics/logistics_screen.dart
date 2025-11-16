// Archivo: /lib/modules/logistics/logistics_screen.dart (CÓDIGO COMPLETO Y CORREGIDO)

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:ihc_project/providers/logistics_provider.dart';
import 'package:ihc_project/modules/logistics/logistics_image_display.dart'; 
import 'package:ihc_project/modules/logistics/image_upload_modal.dart'; 
import 'package:ihc_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// Definición de colores (manteniendo el rojo de tu diseño)
const Color kPrimaryRed = Color(0xFFC62828); 

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({super.key});

  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  String _selectedDay = 'Día 1'; // Estado local para el día seleccionado

  @override
  Widget build(BuildContext context) {
    // Obtenemos los providers necesarios
    final logisticsProvider = Provider.of<LogisticsProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final isCoordinator = authProvider.isCoordinator; // Control de rol
    final imagePath = logisticsProvider.getImagePath(_selectedDay);

// Método para eliminar y limpiar la imagen del día
    void _deleteImage() {
      // Usamos un diálogo de confirmación antes de borrar
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.red)),
            content: const Text('¿Estás seguro de que deseas eliminar la imagen de logística de este día?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // 1. Ejecutar la eliminación
                  logisticsProvider.clearImagePath(_selectedDay);
                  
                  // 2. Cerrar el diálogo
                  Navigator.of(dialogContext).pop();
                  
                  // 3. 🆕 Mostrar SnackBar con fondo rojo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🗑️ Logística eliminada con éxito.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- BARRA SUPERIOR (AppBar) ---
          SliverAppBar(
            title: const Text(
              'Módulo de Logística',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            pinned: true,
            floating: true,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Logo de GenerApp en la esquina derecha
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  'lib/assets/images/logo.png',
                  height: 32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          // --- Selector de Días ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Día Actual',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Selector de Días (reutiliza la lógica de Asistencia)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedDay,
                      icon: const Icon(Icons.arrow_drop_down),
                      underline: const SizedBox(),
                      items: [
                        // Lista de días del AttendanceProvider (compartida)
                        ...attendanceProvider.days.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        
                        // RESTRICCIÓN: Solo mostramos la opción 'Agregar día' si es Coordinador
                        if (isCoordinator) 
                          DropdownMenuItem<String>(
                            value: 'Agregar día',
                            child: Row(
                              children: const [
                                Icon(Icons.add, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Agregar día', style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue == 'Agregar día') {
                            // Ejecuta la lógica SÓLO si es Coordinador (ya verificamos en el if anterior)
                            if (isCoordinator) { 
                              final newDayNumber = attendanceProvider.days.length + 1;
                              final newDayName = 'Día $newDayNumber';
                              attendanceProvider.addDay(newDayName);
                              _selectedDay = newDayName;
                            }
                          } else {
                            _selectedDay = newValue!;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- Contenido Principal de Logística (Gestor de Imágenes) ---
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mostrar Imagen o Placeholder
                    LogisticsImageDisplay(
                      imagePath: imagePath,
                      // Lógica de acceso: SOLO EL COORDINADOR PUEDE HACER TAP
                      onAddOrEdit: isCoordinator 
                          ? () => _showImageUploadModal(context, _selectedDay)
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Acceso denegado: Solo Coordinadores pueden editar la logística.')),
                              );
                            },
                      isEditable: isCoordinator,
                      // Llama al nuevo _deleteImage con diálogo y SnackBar rojo
                      onDelete: isCoordinator && imagePath != null ? _deleteImage : null, 
                      // Solo permite eliminar si es Coordinador Y ya hay una imagen cargada
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageUploadModal(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageUploadModal(day: day),
    );
  }
}