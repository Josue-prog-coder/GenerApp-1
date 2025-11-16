// Archivo: /lib/modules/finances/modals/add_product_modal.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/models/product_model.dart';
import 'package:ihc_project/providers/finances_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Necesitas agregar 'uuid: ^4.3.3' a pubspec.yaml

class AddProductModal extends StatefulWidget {
  final Product? productToEdit;

  const AddProductModal({super.key, this.productToEdit});

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.toStringAsFixed(2);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final financeProvider = Provider.of<FinancesProvider>(context, listen: false);
    
    // Bandera para determinar qué mensaje mostrar
    final bool isEditing = widget.productToEdit != null;

    if (!isEditing) {
      // Crear nuevo producto
      final newProduct = Product(id: const Uuid().v4(), name: name, price: price);
      financeProvider.addProduct(newProduct);
    } else {
      // Modificar producto existente
      final updatedProduct = widget.productToEdit!.copyWith(name: name, price: price);
      financeProvider.updateProduct(updatedProduct);
    }

    // 💡 NUEVA FUNCIONALIDAD: Mostrar SnackBar de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing 
            ? '📝 Producto "$name" modificado con éxito.'
            : '✅ Producto "$name" agregado con éxito.', // Mensaje de producto agregado
        ),
        backgroundColor: isEditing ? Colors.blue : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el estilo de los campos de texto
    Widget buildTextField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text}) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
            ),
          ],
        );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24.0),
      title: Text(widget.productToEdit == null ? 'Añadir producto' : 'Modificar producto', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextField(controller: _nameController, label: 'Nombre'),
            const SizedBox(height: 16),
            buildTextField(
              controller: _priceController,
              label: 'Precio',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 30),
            
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
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('Guardar'),
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