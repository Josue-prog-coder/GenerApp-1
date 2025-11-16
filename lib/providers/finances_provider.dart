// Archivo: /lib/providers/finances_provider.dart

import 'package:flutter/material.dart';
import 'package:ihc_project/models/product_model.dart';

class FinancesProvider extends ChangeNotifier {
  // --- CATALOGO DE PRODUCTOS ---
  final List<Product> _products = [
    // Datos de prueba iniciales
    Product(id: '1', name: 'Vaso de Fruta', price: 15.00),
    Product(id: '2', name: 'Agua 500 ml', price: 10.00),
    Product(id: '3', name: 'Gordita De Azúcar', price: 5.00),
    Product(id: '4', name: 'Sticker Pequeño', price: 2.00),
    Product(id: '5', name: 'Sticker Mediano', price: 5.00),
    Product(id: '6', name: 'Bolsa de Palomitas', price: 10.00),
    Product(id: '7', name: 'Pin', price: 5.00),
  ];

  // --- PUNTO DE VENTA (Carrito Actual) ---
  final List<SaleItem> _currentSale = [];
  
  // --- ESTADÍSTICAS (Ingresos Acumulados) ---
  double _dailyRevenue = 0.00;
  
  // --- BÚSQUEDA ---
  String _productSearchQuery = '';

  // Getters
  List<Product> get products => _products;
  List<SaleItem> get currentSale => _currentSale;
  double get dailyRevenue => _dailyRevenue;
  double get saleTotal => _currentSale.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  // ----------------------------------------------------
  // --- GESTIÓN DE PRODUCTOS (Coordinador) ---
  // ----------------------------------------------------

  // 💡 CAMBIO: Usamos insert(0, ...) para agregar al principio.
  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
  
  // ----------------------------------------------------
  // --- GESTIÓN DE VENTA (Staff/Coordinador) ---
  // ----------------------------------------------------

  void addItemToSale(Product product) {
    final existingItem = _currentSale.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => SaleItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      _currentSale.add(SaleItem(product: product, quantity: 1));
    } else {
      existingItem.quantity++;
    }
    notifyListeners();
  }
  
  void adjustSaleItemQuantity(SaleItem item, int change) {
    item.quantity += change;
    
    if (item.quantity <= 0) {
      _currentSale.remove(item);
    }
    notifyListeners();
  }
  
  void completeSale() {
    _dailyRevenue += saleTotal;
    _currentSale.clear();
    notifyListeners();
  }
  
  void cancelSale() {
    _currentSale.clear();
    notifyListeners();
  }
  
  // ----------------------------------------------------
  // --- BÚSQUEDA ---
  // ----------------------------------------------------

  void setSearchQuery(String query) {
    _productSearchQuery = query;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    if (_productSearchQuery.isEmpty) {
      return _products;
    }
    final query = _productSearchQuery.toLowerCase();
    return _products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }
}