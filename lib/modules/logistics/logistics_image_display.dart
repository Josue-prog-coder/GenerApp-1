// Archivo: /lib/modules/logistics/logistics_image_display.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- Nuevo import para Firebase URLs

enum LogisticsAction { delete, openExternal } 

// =========================================================================
// WIDGET DEDICADO PARA LA VISTA DE ZOOM CON DOBLE TOQUE
// =========================================================================

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  final TransformationController _controller = TransformationController();

  void _onDoubleTap(TapDownDetails details) {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final double zoomFactor = 2.0; 
      
      final double zoomX = -details.localPosition.dx * (zoomFactor - 1.0);
      final double zoomY = -details.localPosition.dy * (zoomFactor - 1.0);

      _controller.value = Matrix4.identity()
        ..translate(zoomX, zoomY)
        ..scale(zoomFactor, zoomFactor);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onDoubleTapDown: (details) => _onDoubleTap(details),
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.network( // <-- Cambiado a Image.network
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              },
              errorBuilder: (context, error, stackTrace) => 
                const Center(child: Text("Error al cargar la imagen completa", style: TextStyle(color: Colors.white))),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET PRINCIPAL: LogisticsImageDisplay
// =========================================================================

class LogisticsImageDisplay extends StatelessWidget {
  final String? imagePath; // <-- Ahora este string contiene una URL web
  final VoidCallback onAddOrEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const LogisticsImageDisplay({
    super.key,
    this.imagePath,
    this.onDelete, 
    required this.onAddOrEdit,
    this.isEditable = true,
  });

  // FUNCIÓN PARA ABRIR EL ARCHIVO (URL) CON EL NAVEGADOR NATIVO
  void _openFileExternally(BuildContext context) async {
    if (imagePath == null) return;
    
    final Uri uri = Uri.parse(imagePath!);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('No se pudo abrir el enlace');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al abrir archivo en el navegador')),
        );
      }
    }
  }

  // FUNCIÓN PARA ABRIR LA IMAGEN EN PANTALLA COMPLETA CON ZOOM
  void _showZoomViewer(BuildContext context) {
    if (imagePath != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return FullScreenImageViewer(imageUrl: imagePath!);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isImageLoaded = imagePath != null && imagePath!.isNotEmpty; 
    
    if (!isImageLoaded) {
      // 1. Vista Inicial (Añadir Imagen) - Placeholder
      return Column(
        children: [
          const Icon(Icons.image_outlined, size: 100, color: Colors.black38),
          const SizedBox(height: 30),
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
      // 2. Vista con Imagen Cargada
      return Column(
        children: [
          // Previsualización (Tap para abrir el visor de zoom)
          GestureDetector(
            onTap: () => _showZoomViewer(context), 
            child: Stack(
              children: [
                // Imagen principal desde Internet
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network( // <-- Cambiado a Image.network
                      imagePath!,
                      fit: BoxFit.cover, 
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Text("Error al descargar imagen desde Firebase")),
                    ),
                  ),
                ),
                
                // <<< MENÚ DE OPCIONES >>>
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: PopupMenuButton<LogisticsAction>(
                      onSelected: (LogisticsAction result) {
                        if (result == LogisticsAction.delete && onDelete != null) {
                          onDelete!();
                        } else if (result == LogisticsAction.openExternal) {
                          _openFileExternally(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<LogisticsAction>>[
                        // OPCIÓN 1: ABRIR EXTERNAMENTE
                        const PopupMenuItem<LogisticsAction>(
                          value: LogisticsAction.openExternal,
                          child: Row(
                            children: [
                              Icon(Icons.open_in_new, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Abrir en Navegador'),
                            ],
                          ),
                        ),
                        // OPCIÓN 2: ELIMINAR (Solo visible si es Coordinador)
                        if (onDelete != null)
                          const PopupMenuItem<LogisticsAction>(
                            value: LogisticsAction.delete,
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar Logística'),
                              ],
                            ),
                          ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- Mensaje de Orientación/Zoom ---
          const Text(
            'Toca la imagen para hacer zoom / Se recomienda rotar el dispositivo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.blueGrey),
          ),
          const SizedBox(height: 20),

          // --- Fila de Botones ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón de Edición (Solo si es editable)
              if (isEditable)
                OutlinedButton.icon(
                  onPressed: onAddOrEdit,
                  icon: const Icon(Icons.edit, color: Colors.red),
                  label: const Text('Cambiar Imagen', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                ),
            ],
          ),
        ],
      );
    }
  }
}