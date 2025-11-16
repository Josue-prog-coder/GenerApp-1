// Archivo: /lib/modules/finances/modals/product_selection_modal.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/models/product_model.dart';
import 'package:ihc_project/providers/finances_provider.dart';
import 'package:provider/provider.dart';

class ProductSelectionModal extends StatelessWidget {
  const ProductSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinancesProvider>(context);
    final products = financeProvider.products;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Añadir a la venta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const Divider(),
          
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductSelectionTile(product: product);
              },
            ),
          ),
          
          const Divider(),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class ProductSelectionTile extends StatelessWidget {
  final Product product;

  const ProductSelectionTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinancesProvider>(context, listen: false);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
      child: ListTile(
        title: Text('${product.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
          onPressed: () {
            financeProvider.addItemToSale(product);
            // Opcional: Mostrar un SnackBar de confirmación
          },
        ),
      ),
    );
  }
}