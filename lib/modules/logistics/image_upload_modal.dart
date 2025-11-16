// Archivo: /lib/modules/logistics/image_upload_modal.dart (CÓDIGO CORREGIDO PARA ALERTAS)

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/logistics_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Para manejar archivos de imagen (simulación)
import 'package:image_picker/image_picker.dart';

class ImageUploadModal extends StatefulWidget {
  final String day;
  const ImageUploadModal({super.key, required this.day});

  @override
  State<ImageUploadModal> createState() => _ImageUploadModalState();
}

class _ImageUploadModalState extends State<ImageUploadModal> {
  String? _tempImagePath;
  
  // Obtenemos la ruta de la imagen existente al inicializar
  @override
  void initState() {
    super.initState();
    final logisticsProvider = Provider.of<LogisticsProvider>(context, listen: false);
    _tempImagePath = logisticsProvider.getImagePath(widget.day);
  }

  // Lógica de selección de imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); 

    if (pickedFile != null) {
      setState(() {
        _tempImagePath = pickedFile.path;
      });
    }
  }
  
  // Lógica de guardado
  void _saveImage() {
    if (_tempImagePath != null) {
      // Guardar la ruta en el Provider
      Provider.of<LogisticsProvider>(context, listen: false)
          .saveImagePath(widget.day, _tempImagePath!);
      
      // 🆕 NUEVA FUNCIONALIDAD: Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Imagen subida con éxito.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.pop(context); // Cerrar modal
  }
  
  @override
  Widget build(BuildContext context) {
    // La etiqueta del botón rojo cambia si ya hay una imagen en previsualización
    final bool imageSelected = _tempImagePath != null;
    final String redButtonLabel = imageSelected ? 'Cambiar Archivo' : 'Subir archivo';
    
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Subir imagen',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Contenedor de Previsualización (Ajustamos tamaño para el diseño)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(8), // Padding para la previsualización
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: imageSelected
                      ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                                File(_tempImagePath!), 
                                fit: BoxFit.contain, // Usamos contain para ver toda la imagen dentro del recuadro
                                errorBuilder: (context, error, stackTrace) => 
                                  const Center(child: Text("Error de previsualización")),
                            ),
                          )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image_outlined, size: 50, color: Colors.black54),
                            SizedBox(height: 8),
                            Text('Cargar desde el dispositivo', style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón Subir/Cambiar Archivo (Botón Rojo)
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(redButtonLabel, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Botones de Acción (Cancelar y Guardar)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saveImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}