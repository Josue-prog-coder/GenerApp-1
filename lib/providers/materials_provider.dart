// Archivo: /lib/providers/materials_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Nuevo Import

// Modelo actualizado para un archivo cargado desde Firebase
class MaterialItem {
  final String id;         // ID del documento en Firestore
  final String path;       // URL de descarga en Firebase Storage (ya no es ruta local)
  final String fileName;   // Nombre original del archivo
  final String fileType;   // 'pdf', 'pptx', 'image'
  final DateTime? dateAdded; // Fecha/hora de subida convertida a DateTime

  MaterialItem({
    required this.id,
    required this.path,
    required this.fileName,
    required this.fileType,
    required this.dateAdded,
  });
}

class MaterialsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mapa para guardar una LISTA de archivos por día (Sincronizado con Firebase)
  // Ejemplo: { 'Día 1': [MaterialItem1, MaterialItem2], 'Día 2': [] }
  final Map<String, List<MaterialItem>> _materialsByDay = {};

  MaterialsProvider() {
    _listenToMaterials();
  }

  // Escucha toda la colección en tiempo real, agrupándola automáticamente por día
  void _listenToMaterials() {
    _firestore
        .collection('materiales')
        .orderBy('fecha_subida', descending: true)
        .snapshots()
        .listen((snapshot) {
      _materialsByDay.clear();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final day = data['dia_sesion'] as String?;
        
        if (day != null) {
          final item = MaterialItem(
            id: doc.id,
            path: data['url_archivo'] ?? '',
            fileName: data['titulo'] ?? '',
            fileType: data['tipo_archivo'] ?? '',
            dateAdded: (data['fecha_subida'] as Timestamp?)?.toDate(),
          );

          if (!_materialsByDay.containsKey(day)) {
            _materialsByDay[day] = [];
          }
          _materialsByDay[day]!.add(item);
        }
      }
      notifyListeners(); // Redibuja la interfaz al instante
    });
  }

  // Método para obtener los materiales de un día específico
  List<MaterialItem> getMaterialsForDay(String day) {
    return _materialsByDay[day] ?? [];
  }

  // Método para agregar un nuevo archivo
  // NOTA: 'downloadUrl' debe ser el link público que te devuelve Firebase Storage al subir el archivo físico
  Future<void> addMaterial(String day, String fileName, String fileType, String downloadUrl) async {
    try {
      await _firestore.collection('materiales').add({
        'dia_sesion': day,
        'titulo': fileName,
        'tipo_archivo': fileType,
        'url_archivo': downloadUrl,
        'fecha_subida': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error al agregar material: $e");
    }
  }

  // Método para eliminar un archivo usando el índice (como lo tenías en tu UI)
  Future<void> removeMaterial(String day, int index) async {
    if (_materialsByDay.containsKey(day) && index >= 0 && index < _materialsByDay[day]!.length) {
      try {
        // 1. Obtenemos el ID del documento en Firebase antes de borrarlo
        final docId = _materialsByDay[day]![index].id;
        
        // 2. Eliminación optimista local para que desaparezca de la pantalla al instante
        _materialsByDay[day]!.removeAt(index);
        notifyListeners();

        // 3. Lo eliminamos permanentemente de Firestore
        await _firestore.collection('materiales').doc(docId).delete();
      } catch (e) {
        debugPrint("Error al eliminar material: $e");
      }
    }
  }
}