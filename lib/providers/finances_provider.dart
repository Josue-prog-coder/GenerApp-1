// Archivo: /lib/providers/finances_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Nuevo Import
import 'package:ihc_project/models/product_model.dart';

class FinancesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CATALOGO DE PRODUCTOS ---
  List<Product> _products = [];

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
  
  // Constructor: Inicia la escucha de datos en Firebase
  FinancesProvider() {
    _listenToProducts();
    _listenToDailyRevenue();
  }

  // Escucha los productos en tiempo real desde Firestore
  void _listenToProducts() {
    _firestore.collection('productos').orderBy('nombre').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['nombre'] ?? '',
          price: (data['precio'] ?? 0).toDouble(),
        );
      }).toList();
      notifyListeners();
    });
  }

  // Escucha las ventas de HOY para calcular los ingresos en tiempo real
  void _listenToDailyRevenue() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    _firestore.collection('ventas')
        .where('fecha_registro', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots()
        .listen((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['total'] ?? 0).toDouble();
      }
      _dailyRevenue = total;
      notifyListeners();
    });
  }

  // ----------------------------------------------------
  // --- GESTIÓN DE PRODUCTOS (Coordinador) ---
  // ----------------------------------------------------

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('productos').add({
        'nombre': product.name,
        'precio': product.price,
      });
    } catch (e) {
      debugPrint("Error al agregar producto: $e");
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('productos').doc(product.id).update({
        'nombre': product.name,
        'precio': product.price,
      });
    } catch (e) {
      debugPrint("Error al actualizar producto: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('productos').doc(id).delete();
    } catch (e) {
      debugPrint("Error al eliminar producto: $e");
    }
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
  
  Future<void> completeSale() async {
    if (_currentSale.isEmpty) return;

    try {
      // Preparamos el resumen de los items vendidos
      final itemsList = _currentSale.map((item) => {
        'id_producto': item.product.id,
        'nombre': item.product.name,
        'cantidad': item.quantity,
        'subtotal': item.totalPrice,
      }).toList();

      // Guardamos la venta en Firebase
      await _firestore.collection('ventas').add({
        'total': saleTotal,
        'items': itemsList,
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      // Limpiamos el carrito local
      _currentSale.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Error al completar la venta: $e");
    }
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