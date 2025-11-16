// Archivo: /lib/modules/attendance/add_participant_screen.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/providers/participant_provider.dart';

class AddParticipantScreen extends StatefulWidget {
  final Participant? participantToEdit;
  final int? index;

  const AddParticipantScreen({super.key, this.participantToEdit, this.index});

  @override
  State<AddParticipantScreen> createState() => _AddParticipantScreenState();
}

class _AddParticipantScreenState extends State<AddParticipantScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // 📢 CAMBIO: Eliminamos las variables de estado de rol de aquí.
  // Los roles originales se guardarán y devolverán en _saveParticipant.
  late bool _initialIsLeader;
  late bool _initialIsAmbassador;


  @override
  void initState() {
    super.initState();
    if (widget.participantToEdit != null) {
      _nameController.text = widget.participantToEdit!.name;
      _phoneController.text = widget.participantToEdit!.phone;
      // Guardamos los roles originales para que no se pierdan al devolver el objeto
      _initialIsLeader = widget.participantToEdit!.isLeader;
      _initialIsAmbassador = widget.participantToEdit!.isAmbassador;
    } else {
      _initialIsLeader = false;
      _initialIsAmbassador = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveParticipant() {
    // Devolvemos el participante completo con los datos editados
    // y manteniendo los roles originales.
    final updatedParticipant = Participant(
      name: _nameController.text,
      phone: _phoneController.text,
      isLeader: _initialIsLeader, 
      isAmbassador: _initialIsAmbassador, 
    );
    Navigator.pop(context, updatedParticipant);
  }

  @override
  Widget build(BuildContext context) {
    // Para hacer la tarjeta más grande, usamos el 85% del ancho de la pantalla.
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Participante', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView( // Usamos SingleChildScrollView para evitar desbordamiento
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              // Establecemos el ancho máximo para que se vea más grande
              width: screenWidth * 0.85,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar datos básicos', // Texto actualizado
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 28), // Más espacio

                  // Campos de Nombre y Teléfono
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre',
                  ),
                  const SizedBox(height: 20), // Más espacio
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    keyboardType: TextInputType.phone,
                  ),
                  
                  // 📢 CAMBIO: Eliminada la UI de los botones de rol (Destacado/Embajador)

                  const SizedBox(height: 36), // Mantener el espacio antes de los botones de acción

                  // Botones de Cancelar y Guardar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón Cancelar (Borde Rojo, Fondo Blanco)
                      Expanded(
                        child: _buildActionButton(
                          label: 'Cancelar',
                          color: Colors.red,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Botón Guardar (Borde Verde, Fondo Blanco)
                      Expanded(
                        child: _buildActionButton(
                          label: 'Guardar',
                          color: Colors.green,
                          onPressed: _saveParticipant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  // Widget para construir el campo de texto con el estilo del diseño
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
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Nuevo Widget para los botones de Acción (Cancelar/Guardar)
  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // INICIALMENTE: Fondo Blanco, Borde del Color
        backgroundColor: Colors.white,
        foregroundColor: color, // Color del texto
        side: BorderSide(color: color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}