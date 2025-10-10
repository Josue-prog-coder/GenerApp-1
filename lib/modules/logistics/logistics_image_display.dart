// Archivo: /lib/modules/logistics/logistics_image_display.dart

import 'package:flutter/material.dart';
import 'dart:io'; 

class LogisticsImageDisplay extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onAddOrEdit;
  final bool isEditable; 

  const LogisticsImageDisplay({
    super.key,
    this.imagePath,
    required this.onAddOrEdit,
    this.isEditable = true,
  });

  // Método para mostrar la imagen en pantalla completa
  void _showFullScreenImage(BuildContext context) {
    if (imagePath != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              body: Center(
                // Permite el scroll para imágenes grandes
                child: SingleChildScrollView( 
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.contain, // Muestra la imagen completa
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      // 1. Vista Inicial (Añadir Imagen)
      return Column(
        children: [
          const Icon(Icons.image_outlined, size: 100, color: Colors.black38),
          const SizedBox(height: 30),
          // Solo mostrar botón si es editable
          if (isEditable) 
            ElevatedButton.icon(
              onPressed: onAddOrEdit,
              icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
              label: const Text('Añadir Imagen', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          if (!isEditable)
            const Text('Logística aún no cargada.', style: TextStyle(color: Colors.grey)),
        ],
      );
    } else {
      // 2. Vista con Imagen Cargada (Editar/Previsualización)
      return Column(
        children: [
          // Previsualización (al hacer tap, activa el visor de pantalla completa)
          GestureDetector(
            onTap: () => _showFullScreenImage(context), // Pasamos el contexto correctamente
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!), 
                  fit: BoxFit.cover, // Usamos cover para que se vea bien en el contenedor pequeño
                  errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Text("Error al cargar imagen")),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Botón de Edición (Solo visible si es editable)
          if (isEditable) // Control de acceso
            OutlinedButton.icon(
              onPressed: onAddOrEdit,
              icon: const Icon(Icons.edit, color: Colors.red),
              label: const Text('Cambiar Imagen', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
        ],
      );
    }
  }
}