// Archivo: /lib/modules/materials/materials_screen.dart (CÓDIGO FINAL Y FUNCIONAL CON SNACKBARS Y ESTILOS DE DIÁLOGO)

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:ihc_project/providers/materials_provider.dart';
import 'package:ihc_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ihc_project/modules/materials/material_card.dart';
import 'package:open_filex/open_filex.dart'; // Import necesario
import 'dart:io';

// CLASE AUXILIAR ESTÁTICA PARA MANEJAR LA LÓGICA DE ARCHIVOS
class FileActions {
  // Función para abrir el archivo con la app nativa del dispositivo
  static void openExternally(BuildContext context, String path) async {
    final result = await OpenFilex.open(path);

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir archivo: ${result.message}')),
      );
    }
  }

  // Función modificada para mostrar el diálogo de advertencia
  static void showFileConfirmation(BuildContext context, MaterialItem material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Archivo'),
        content: Text('Estás a punto de salir de GenerApp para ver el archivo "${material.fileName}". ¿Confirmas?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context), // 1. Cierra el diálogo
          ),
          ElevatedButton(
            child: const Text('Confirmar'),
            onPressed: () {
              Navigator.pop(context); // 1. Cierra el diálogo
              openExternally(context, material.path); // 2. Abre el archivo
            },
          ),
        ],
      ),
    );
  }
}

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String _selectedDay = 'Día 1';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  // --- FUNCIÓN DE SUBIDA DE ARCHIVOS (MODIFICADA PARA SNACKBAR) ---
  Future<void> _pickFiles(BuildContext context) async {
    final pickedFile = await _picker.pickMedia();

    if (pickedFile != null) {
      String fileType = pickedFile.name.endsWith('.pdf')
          ? 'pdf'
          : (pickedFile.name.endsWith('.pptx') ? 'pptx' : 'image');

      final newMaterial = MaterialItem(
        path: pickedFile.path,
        fileName: pickedFile.name,
        fileType: fileType,
        dateAdded: DateTime.now().toIso8601String().substring(0, 10),
      );

      Provider.of<MaterialsProvider>(context, listen: false)
          .addMaterial(_selectedDay, newMaterial);
      
      // 🆕 MOSTRAR ALERTA DE ÉXITO AL AÑADIR (FONDO VERDE)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Material "${newMaterial.fileName}" añadido con éxito.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // --- FUNCIÓN DE ELIMINACIÓN (MODIFICADA PARA DIÁLOGO Y SNACKBAR ROJO) ---
  void _confirmDelete(BuildContext context, String day, int index, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // 💡 CAMBIO: Título en rojo
        title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.red)),
        content: Text('¿Estás seguro de que deseas eliminar el archivo "$fileName"? Esta acción no se puede deshacer.'),
        actions: [
          // 💡 CAMBIO: Botón Cancelar tenue (solo texto)
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
            onPressed: () => Navigator.pop(context),
          ),
          // 💡 CAMBIO: Botón Eliminar sólido y rojo
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              // 1. Eliminar del Provider
              Provider.of<MaterialsProvider>(context, listen: false)
                  .removeMaterial(day, index);
              // 2. Cerrar diálogo
              Navigator.pop(context);
              // 3. 🆕 MOSTRAR ALERTA DE ÉXITO (FONDO ROJO)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Archivo "$fileName" eliminado con éxito.'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR SELECTOR DE DÍA (Se mantiene igual) ---
  Widget _buildDaySelector(AttendanceProvider attendanceProvider, bool isCoordinator) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Día Actual',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedDay,
            icon: const Icon(Icons.arrow_drop_down),
            underline: const SizedBox(),
            items: [
              ...attendanceProvider.days.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),
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
    );
  }

  // --- WIDGET BUILD PRINCIPAL (Se mantiene igual) ---
  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final materialsProvider = Provider.of<MaterialsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final isCoordinator = authProvider.isCoordinator;
    final materialsList = materialsProvider.getMaterialsForDay(_selectedDay);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- BARRA SUPERIOR (AppBar) ---
          SliverAppBar(
            title: const Text(
              'Temas y Dinámicas', 
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
          
          // --- Selector de Días y Botón de Subida ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDaySelector(attendanceProvider, isCoordinator),
                  const SizedBox(height: 16),

                  // Botón de Añadir Archivo (SOLO PARA COORDINADOR)
                  if (isCoordinator)
                    ElevatedButton.icon(
                      onPressed: () => _pickFiles(context),
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      label: const Text('Añadir Material', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  if (!isCoordinator)
                    const Text('Solo Coordinadores pueden subir material.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          // --- Lista de Archivos Cargados ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final material = materialsList[index];
                  return MaterialCard(
                    item: material,
                    // Llama al auxiliar de confirmación y apertura
                    onTap: () => FileActions.showFileConfirmation(context, material), 
                    onDelete: isCoordinator 
                        ? () => _confirmDelete(context, _selectedDay, index, material.fileName)
                        : null,
                  );
                },
                childCount: materialsList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}