// Archivo: /lib/modules/finances/tabs/products_tab.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/models/product_model.dart';
import 'package:ihc_project/providers/auth_provider.dart';
import 'package:ihc_project/providers/finances_provider.dart';
import 'package:ihc_project/modules/finances/modals/add_product_modal.dart';
import 'package:provider/provider.dart';

class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  void _showAddProductModal(BuildContext context, {Product? product, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AddProductModal(productToEdit: product),
    );
  }

  // 🆕 NUEVO: Lógica de eliminación con diálogo de confirmación
  void _confirmDelete(BuildContext context, Product product) {
    final financeProvider = Provider.of<FinancesProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.red)),
          content: Text('¿Estás seguro de que deseas eliminar el producto "${product.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                // 1. Eliminar del Provider
                financeProvider.deleteProduct(product.id);
                // 2. Cerrar el diálogo
                Navigator.of(dialogContext).pop();
                // 3. Mostrar un SnackBar de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ Producto "${product.name}" eliminado con éxito.'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinancesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    // Control de acceso para edición/eliminación
    final isCoordinator = authProvider.isCoordinator;
    final products = financeProvider.filteredProducts;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de búsqueda
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar producto...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: (value) => financeProvider.setSearchQuery(value),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Botón Agregar Producto (SOLO COORDINADOR)
                if (isCoordinator)
                  ElevatedButton.icon(
                    onPressed: () => _showAddProductModal(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Agregar Producto', style: TextStyle(color: Colors.white, fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // Lista de Productos
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                // Si es Coordinador, pasamos el callback de edición y el nuevo callback de eliminación
                onEdit: isCoordinator ? () => _showAddProductModal(context, product: product) : null,
                onDelete: isCoordinator ? () => _confirmDelete(context, product) : null,
              );
            },
            childCount: products.length,
          ),
        ),
      ],
    );
  }
}

// Tarjeta de Producto (Producto, Precio Unitario, Lápiz de Edición y Basura)
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;   // Lápiz
  final VoidCallback? onDelete; // Basura

  const ProductCard({super.key, required this.product, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      child: ListTile(
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
        // 🆕 NUEVO: Usamos un Row para contener los dos botones
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Esto es crucial para que Row ocupe poco espacio
          children: [
            // Botón de Edición (Lápiz)
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: onEdit,
              ),
            // Botón de Eliminación (Basura)
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}