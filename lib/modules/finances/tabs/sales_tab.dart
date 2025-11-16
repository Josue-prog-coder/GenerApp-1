// Archivo: /lib/modules/finances/tabs/sales_tab.dart (CÓDIGO CORREGIDO PARA CONFIRMACIONES)

import 'package:flutter/material.dart';
import 'package:ihc_project/models/product_model.dart';
import 'package:ihc_project/providers/finances_provider.dart';
import 'package:ihc_project/modules/finances/modals/product_selection_modal.dart';
import 'package:provider/provider.dart';

class SalesTab extends StatelessWidget {
  const SalesTab({super.key});

  void _showProductSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ProductSelectionModal(),
    );
  }

  // 🆕 FUNCIÓN: Maneja la lógica de guardar/completar la venta
  void _handleCompleteSale(BuildContext context, FinancesProvider provider) {
    if (provider.currentSale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No hay productos en la venta para guardar.')),
      );
      return;
    }

    // 1. Mostrar diálogo de confirmación para Guardar
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Venta'),
          content: Text('¿Desea completar la venta por \$${provider.saleTotal.toStringAsFixed(2)}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                // 2. Ejecutar la acción
                provider.completeSale();
                Navigator.of(dialogContext).pop();
                
                // 3. Mostrar alerta de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 ¡Venta Exitosa! Ingresos registrados.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // 🆕 FUNCIÓN: Maneja la lógica de cancelar la venta
  void _handleCancelSale(BuildContext context, FinancesProvider provider) {
    if (provider.currentSale.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No hay productos en la venta para cancelar.')),
      );
      return;
    }

// 1. Mostrar diálogo de confirmación para Cancelar
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cancelación'),
          // 💡 CAMBIO: Eliminamos "Comentario:"
          content: const Text('¿Desea cancelar la compra actual? Se perderán todos los artículos añadidos.'),
          
          // 💡 CAMBIO: Usamos Row para botones horizontales y estilizados
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Alineamos a la derecha
              children: [
                // 1. Botón Secundario (No, Seguir Comprando)
                TextButton(
                  child: const Text('Seguir Comprando', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                const SizedBox(width: 8),
                // 2. Botón Principal (Sí, Cancelar) - Sólido y Rojo
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Rojo más notorio
                  child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // 2. Ejecutar la acción
                    provider.cancelSale();
                    Navigator.of(dialogContext).pop();

                    // 3. Mostrar alerta de cancelación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Compra Cancelada. El carrito ha sido vaciado.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinancesProvider>(context);
    final saleItems = financeProvider.currentSale;
    final total = financeProvider.saleTotal;

    return Column(
      children: [
        // --- Botón Agregar a la Venta ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showProductSelectionModal(context),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text('Agregar a la venta', style: TextStyle(color: Colors.white, fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        
        // --- Tabla de Productos en Venta ---
        Expanded( 
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildTableHeader(),
                const Divider(height: 1, thickness: 1, color: Colors.grey),
                // Lista de productos en la venta
                ...saleItems.map((item) => _buildSaleRow(context, item)).toList(),
              ],
            ),
          ),
        ),
        
        // --- Total y Botones de Acción ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recuadro Total
              ElevatedButton(
                onPressed: () {}, // No hace nada, solo muestra el total
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              // Botones Cancelar y Guardar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // 💡 Llama a la función de cancelación con confirmación
                      onPressed: () => _handleCancelSale(context, financeProvider),
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
                      // 💡 Llama a la función de guardar con confirmación
                      onPressed: () => _handleCompleteSale(context, financeProvider),
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
      ],
    );
  }
  
  // Widget para el encabezado de la tabla (Se mantiene)
  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('P. Unitario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Cant.', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  // Widget para cada fila de la venta (Se mantiene)
  Widget _buildSaleRow(BuildContext context, SaleItem item) {
    final financeProvider = Provider.of<FinancesProvider>(context, listen: false);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(item.product.name, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text('\$${item.product.price.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text('${item.quantity}', textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('\$${item.totalPrice.toStringAsFixed(2)}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 2, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => financeProvider.adjustSaleItemQuantity(item, 1),
                  child: const Icon(Icons.add_circle, color: Colors.green, size: 24),
                ),
                GestureDetector(
                  onTap: () => financeProvider.adjustSaleItemQuantity(item, -1),
                  child: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}