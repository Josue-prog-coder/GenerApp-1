// Archivo: /lib/modules/materials/material_card.dart (MODIFICADO)

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/materials_provider.dart';

class MaterialCard extends StatelessWidget {
  final MaterialItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MaterialCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
  });

  // 1. Determina el ICONO basado en el tipo de archivo (PPTX con iniciales)
  Widget _getIconForType(String type) {
    switch (type) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, size: 30, color: Colors.red);
      case 'pptx':
        // Usamos un Stack/Container para simular las iniciales PPTX
        return Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.orange.shade800, // Color típico de PowerPoint
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('PPT', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        );
      case 'image':
        return const Icon(Icons.image, size: 30, color: Colors.red);
      default:
        return const Icon(Icons.insert_drive_file, size: 30, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap, // El onTap ahora abrirá la vista previa
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Vista previa (simulación de la primera hoja)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: _getIconForType(item.fileType)), // <-- Usamos el nuevo widget
              ),
              const SizedBox(width: 16),
              
              // Nombre del Archivo y Metadatos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tipo: ${item.fileType.toUpperCase()} | Subido: ${item.dateAdded}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Botón de Eliminación
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}