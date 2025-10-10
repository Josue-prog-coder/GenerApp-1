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
  
  bool _isLeader = false; // Líder Destacado (Estrella)
  bool _isAmbassador = false; // Embajador Generoso (Insignia)

  @override
  void initState() {
    super.initState();
    if (widget.participantToEdit != null) {
      _nameController.text = widget.participantToEdit!.name;
      _phoneController.text = widget.participantToEdit!.phone;
      _isLeader = widget.participantToEdit!.isLeader;
      _isAmbassador = widget.participantToEdit!.isAmbassador;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveParticipant() {
    final newParticipant = Participant(
      name: _nameController.text,
      phone: _phoneController.text,
      isLeader: _isLeader,
      isAmbassador: _isAmbassador,
    );
    Navigator.pop(context, newParticipant);
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
                    'Editar participante',
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
                  const SizedBox(height: 36), // Más espacio

                  // Botones de Rol (Destacado y Embajador)
                  Row(
                    // Aumentamos el espacio entre los botones de rol
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      // Botón Destacado (Líder)
                      Expanded(
                        child: _buildRoleButton(
                          label: 'Destacado',
                          isSelected: _isLeader,
                          onPressed: () {
                            setState(() {
                              _isLeader = !_isLeader;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16), // Separación entre botones de rol
                      // Botón Embajador
                      Expanded(
                        child: _buildRoleButton(
                          label: 'Embajador',
                          isSelected: _isAmbassador,
                          onPressed: () {
                            setState(() {
                              _isAmbassador = !_isAmbassador;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

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
  
  // Widget para construir los botones de Rol con el efecto de color (Destacado/Embajador)
  Widget _buildRoleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    // El color de fondo y borde dependen de si está seleccionado
    final Color buttonColor = isSelected ? const Color(0xFFFFCC00) : Colors.white; // Amarillo fuerte o Blanco
    final Color borderColor = isSelected ? const Color(0xFFFFCC00) : Colors.black; // Borde del color seleccionado o negro
    final Color textColor = Colors.black; // El texto es siempre negro

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        side: BorderSide(color: borderColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14), // Más padding vertical
        elevation: isSelected ? 4 : 0, // Añadir elevación si está seleccionado para resaltarlo
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
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