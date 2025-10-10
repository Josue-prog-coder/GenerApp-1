// Archivo: /lib/providers/logistics_provider.dart

import 'package:flutter/material.dart';

class LogisticsProvider extends ChangeNotifier {
  // Mapa para guardar la ruta de la imagen por día
  // Ejemplo: { 'Día 1': '/ruta/temporal/imagen1.png', 'Día 2': null }
  final Map<String, String?> _logisticsImages = {};

  // Método para obtener la imagen de un día específico
  String? getImagePath(String day) {
    return _logisticsImages[day];
  }

  // Método para guardar/actualizar la imagen de un día
  void saveImagePath(String day, String path) {
    _logisticsImages[day] = path;
    notifyListeners(); // Notifica a la vista para que se redibuje
  }

  // Método para eliminar la imagen (simulación)
  void clearImagePath(String day) {
    _logisticsImages[day] = null;
    notifyListeners();
  }
}