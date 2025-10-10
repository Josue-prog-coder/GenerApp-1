// Archivo: /lib/shared/widgets/add_participant_dialog.dart (CÓDIGO CORREGIDO Y FINAL)

import 'package:flutter/material.dart';

// El widget que se mostrará como diálogo
class AddParticipantDialog extends StatefulWidget {
  const AddParticipantDialog({super.key});

  @override
  State<AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<AddParticipantDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // VARIABLE DE ESTADO para manejar el mensaje de error dentro del diálogo
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveParticipant() {
    // 1. Verificación de Campos Obligatorios
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      
      // Si faltan datos, usamos setState para actualizar el diálogo
      setState(() {
        _errorMessage = 'Nombre y Teléfono son campos obligatorios.';
      });
      return; // Detiene la función aquí
    }
    
    // Si los campos están llenos, procede a guardar y limpiar el error
    final newParticipantData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };
    
    // Cierra el diálogo y devuelve los datos
    Navigator.pop(context, newParticipantData);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      contentPadding: const EdgeInsets.all(28.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      
      content: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth * 0.85, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Añadir participante',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Campo Nombre
              _buildTextField(
                controller: _nameController,
                label: 'Nombre',
              ),
              const SizedBox(height: 20),

              // Campo Teléfono
              _buildTextField(
                controller: _phoneController,
                label: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              
              // MOSTRAR MENSAJE DE ERROR DENTRO DEL DIÁLOGO (Solución al problema de capa)
              if (_errorMessage.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20), // Espacio para cuando no hay error
              ],
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    child: ElevatedButton(
                      onPressed: _saveParticipant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR _buildTextField (Se mantiene igual)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300], // Fondo gris para el campo
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none, // Eliminar el borde del TextField
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}