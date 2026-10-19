// Archivo: /lib/modules/materials/materials_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/attendance_provider.dart';
import 'package:ihc_project/providers/materials_provider.dart';
import 'package:ihc_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_filex/open_filex.dart'; // <-- Restaurado
import 'package:path_provider/path_provider.dart'; // <-- Nuevo import para caché local
import 'package:ihc_project/modules/materials/material_card.dart';
import 'dart:io';

// CLASE AUXILIAR ESTÁTICA PARA MANEJAR LA LÓGICA DE ARCHIVOS
class FileActions {
  // Función para descargar y abrir el archivo con la app nativa del dispositivo
  static Future<void> openExternally(BuildContext context, MaterialItem material) async {
    // 1. Notificar al usuario que la descarga inició
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏳ Descargando "${material.fileName}"...'),
        backgroundColor: Colors.blueGrey,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // 2. Obtener la carpeta temporal del dispositivo
      final tempDir = await getTemporaryDirectory();
      final File localFile = File('${tempDir.path}/${material.fileName}');

      // 3. Descargar el archivo desde Firebase Storage si no existe en caché
      if (!await localFile.exists()) {
        // Usamos material.path que contiene la URL de descarga (Download URL)
        await FirebaseStorage.instance.refFromURL(material.path).writeToFile(localFile);
      }

      // 4. Abrir el archivo localmente con open_filex
      final result = await OpenFilex.open(localFile.path);

      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al abrir archivo: ${result.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al descargar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Función para mostrar el diálogo de advertencia
  static void showFileConfirmation(BuildContext context, MaterialItem material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Archivo'),
        content: Text('Estás a punto de descargar y abrir el archivo "${material.fileName}". ¿Confirmas?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Confirmar'),
            onPressed: () {
              Navigator.pop(context); 
              openExternally(context, material); // Pasamos el objeto material completo
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
  bool _isUploading = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MaterialsProvider>(context, listen: false).setDay(_selectedDay);
    });
  }

  // --- FUNCIÓN DE SUBIDA DE ARCHIVOS A FIREBASE ---
  Future<void> _pickFiles(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx', 'jpg', 'png', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        String fileType = 'documento';
        if (fileName.toLowerCase().endsWith('.pdf')) {
          fileType = 'pdf';
        } else if (fileName.toLowerCase().endsWith('.ppt') || fileName.toLowerCase().endsWith('.pptx')) {
          fileType = 'pptx';
        } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.png') || fileName.toLowerCase().endsWith('.jpeg')) {
          fileType = 'image';
        }

        String safeName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(' ', '_')}';
        Reference ref = FirebaseStorage.instance.ref().child('materiales/$_selectedDay/$safeName');
        
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        if (mounted) {
          await Provider.of<MaterialsProvider>(context, listen: false)
              .addMaterial(_selectedDay, fileName, fileType, downloadUrl);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Material "$fileName" añadido con éxito.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error al subir: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  // --- FUNCIÓN DE ELIMINACIÓN ---
  void _confirmDelete(BuildContext context, String day, int index, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.red)),
        content: Text('¿Estás seguro de que deseas eliminar el archivo "$fileName"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(context); 

              await Provider.of<MaterialsProvider>(context, listen: false)
                  .removeMaterial(day, index);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ Archivo "$fileName" eliminado con éxito.'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR SELECTOR DE DÍA ---
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
              if (newValue == 'Agregar día') {
                if (isCoordinator) {
                  final newDayNumber = attendanceProvider.days.length + 1;
                  final newDayName = 'Día $newDayNumber';
                  attendanceProvider.addDay(newDayName);
                  setState(() {
                    _selectedDay = newDayName;
                  });
                  Provider.of<MaterialsProvider>(context, listen: false).setDay(newDayName);
                }
              } else if (newValue != null) {
                setState(() {
                  _selectedDay = newValue;
                });
                Provider.of<MaterialsProvider>(context, listen: false).setDay(newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final materialsProvider = Provider.of<MaterialsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final isCoordinator = authProvider.isCoordinator;
    final materialsList = materialsProvider.materials;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Temas y Dinámicas', style: TextStyle(color: Colors.white)),
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
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDaySelector(attendanceProvider, isCoordinator),
                  const SizedBox(height: 16),

                  if (isCoordinator)
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : () => _pickFiles(context),
                      icon: _isUploading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.attach_file, color: Colors.white),
                      label: Text(_isUploading ? 'Subiendo material...' : 'Añadir Material', style: const TextStyle(color: Colors.white)),
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
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final material = materialsList[index];
                  return MaterialCard(
                    item: material,
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