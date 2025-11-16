// Archivo: /lib/providers/materials_provider.dart

import 'package:flutter/material.dart';

// Modelo simplificado para un archivo cargado
class MaterialItem {
  final String path;       // Ruta temporal local (simulación de URL/Storage)
  final String fileName;   // Nombre original del archivo
  final String fileType;   // 'pdf', 'pptx', 'image'
  final String dateAdded;  // Fecha/hora de subida (para rastreo)

  MaterialItem({
    required this.path,
    required this.fileName,
    required this.fileType,
    required this.dateAdded,
  });
}

class MaterialsProvider extends ChangeNotifier {
  // Mapa para guardar una LISTA de archivos por día
  // Ejemplo: { 'Día 1': [MaterialItem1, MaterialItem2], 'Día 2': [...] }
  final Map<String, List<MaterialItem>> _materialsByDay = {};

  // Método para obtener los materiales de un día específico
  List<MaterialItem> getMaterialsForDay(String day) {
    // Si el día no existe, devolvemos una lista vacía para evitar errores
    return _materialsByDay[day] ?? [];
  }

  // Método para agregar un nuevo archivo
  void addMaterial(String day, MaterialItem item) {
    if (!_materialsByDay.containsKey(day)) {
      _materialsByDay[day] = [];
    }
    _materialsByDay[day]!.add(item);
    notifyListeners();
  }

  // Método para eliminar un archivo (por nombre o índice, usaremos índice)
  void removeMaterial(String day, int index) {
    if (_materialsByDay.containsKey(day) && index >= 0 && index < _materialsByDay[day]!.length) {
      _materialsByDay[day]!.removeAt(index);
      notifyListeners();
    }
  }
}