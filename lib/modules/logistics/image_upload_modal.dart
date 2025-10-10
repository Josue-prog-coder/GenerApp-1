// Archivo: /lib/modules/logistics/image_upload_modal.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/logistics_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Para manejar archivos de imagen (simulación)
import 'package:image_picker/image_picker.dart'; // <-- Recuerda agregar la dependencia!

class ImageUploadModal extends StatefulWidget {
  final String day;
  const ImageUploadModal({super.key, required this.day});

  @override
  State<ImageUploadModal> createState() => _ImageUploadModalState();
}

class _ImageUploadModalState extends State<ImageUploadModal> {
  String? _tempImagePath;

  // Lógica de selección de imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Simulamos la carga desde la galería (o cámara, si estuviera configurado)
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
    }
    Navigator.pop(context); // Cerrar modal
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1), // Baja el modal
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
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

            // Contenedor de Previsualización
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _tempImagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image_outlined, size: 50, color: Colors.black54),
                            SizedBox(height: 8),
                            Text('Cargar desde el dispositivo', style: TextStyle(color: Colors.black54)),
                          ],
                        )
                      : Image.file(
                          File(_tempImagePath!), // Previsualización de la imagen
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón Subir Archivo (Presionar para activar la galería)
            ElevatedButton(
              onPressed: _pickImage, // Usamos _pickImage para que sea el botón visible
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Subir archivo', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Botones de Acción
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
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
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
                    child: const Text('Guardar', style: TextStyle(fontSize: 16)),
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