// Archivo: /lib/providers/logistics_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Nuevo Import

class LogisticsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mapa para guardar la URL de la imagen por día (Sincronizado con Firebase)
  // Ejemplo: { 'Día 1': 'https://firebasestorage...', 'Día 2': null }
  final Map<String, String?> _logisticsImages = {};

  // Constructor: Inicia la escucha de datos al cargar la app
  LogisticsProvider() {
    _listenToLogisticsData();
  }

  // Escucha en tiempo real la colección de logística en Firestore
  void _listenToLogisticsData() {
    _firestore.collection('logistica').snapshots().listen((snapshot) {
      _logisticsImages.clear();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final day = data['dia_sesion'] as String?;
        final imageUrl = data['url_imagen'] as String?;
        
        if (day != null && imageUrl != null) {
          _logisticsImages[day] = imageUrl;
        }
      }
      notifyListeners(); // Redibuja la vista si el Coordinador cambia la imagen
    });
  }

  // Método para obtener la URL de la imagen de un día específico
  String? getImagePath(String day) {
    return _logisticsImages[day];
  }

  // Método para guardar/actualizar la URL de la imagen de un día
  // El "path" que recibe aquí debe ser la URL pública que te entrega Firebase Storage
  Future<void> saveImagePath(String day, String path) async {
    // 1. Actualización optimista local
    _logisticsImages[day] = path;
    notifyListeners(); 

    // 2. Operación en Firebase Firestore
    try {
      final query = await _firestore
          .collection('logistica')
          .where('dia_sesion', isEqualTo: day)
          .get();

      if (query.docs.isNotEmpty) {
        // Actualiza el documento si el día ya tenía una imagen asignada
        await query.docs.first.reference.update({
          'url_imagen': path,
        });
      } else {
        // Crea un nuevo documento si es la primera vez que se sube logística para este día
        await _firestore.collection('logistica').add({
          'dia_sesion': day,
          'url_imagen': path,
          // 'subido_por': FirebaseAuth.instance.currentUser?.uid, // Opcional si quieres guardar quién lo subió
        });
      }
    } catch (e) {
      debugPrint("Error al guardar la logística en Firebase: $e");
    }
  }

  // Método para eliminar la imagen de un día
  Future<void> clearImagePath(String day) async {
    _logisticsImages[day] = null;
    notifyListeners();

    try {
      final query = await _firestore
          .collection('logistica')
          .where('dia_sesion', isEqualTo: day)
          .get();

      for (var doc in query.docs) {
        await doc.reference.delete(); // Borra el documento de Firestore
      }
    } catch (e) {
      debugPrint("Error al eliminar la logística: $e");
    }
  }
}