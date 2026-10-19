// Archivo: /lib/modules/logistics/image_upload_modal.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/logistics_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // <-- Nuevo Import para Storage

class ImageUploadModal extends StatefulWidget {
  final String day;
  const ImageUploadModal({super.key, required this.day});

  @override
  State<ImageUploadModal> createState() => _ImageUploadModalState();
}

class _ImageUploadModalState extends State<ImageUploadModal> {
  String? _tempImagePath;
  bool _isUploading = false; // <-- Controla el estado de carga
  
  @override
  void initState() {
    super.initState();
    // La imagen inicial aquí era una ruta local en tu código original. 
    // Si viene de Firebase (es un link http), ImagePicker no lo puede previsualizar como File.
    // Solo permitiremos seleccionar una nueva imagen y mostrarla en File.
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
  
  // Lógica de guardado en Firebase Storage
  Future<void> _saveImage() async {
    if (_tempImagePath == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      File file = File(_tempImagePath!);
      
      // Creamos una referencia única en Storage usando el nombre del día y la fecha exacta
      String fileName = 'logistica_${widget.day.replaceAll(' ', '')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('logistica/$fileName');

      // Subimos el archivo a Firebase Storage
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Obtenemos la URL de descarga pública
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Pasamos la URL al provider para que la guarde en Firestore
      if (mounted) {
        await Provider.of<LogisticsProvider>(context, listen: false)
            .saveImagePath(widget.day, downloadUrl);

        // Mostrar SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Imagen subida con éxito.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al subir la imagen: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context); // Cerrar modal
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
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

            // Contenedor de Previsualización
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(8), 
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
                                fit: BoxFit.contain,
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
              onPressed: _isUploading ? null : _pickImage,
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
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
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
                    onPressed: _isUploading ? null : _saveImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isUploading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
                          )
                        : const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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