// Archivo: /lib/models/product_model.dart

class Product {
  final String id;
  String name;
  double price; // Precio unitario

  Product({
    required this.id,
    required this.name,
    required this.price,
  });
  
  // Método para actualizar (útil para edición)
  Product copyWith({
    String? name,
    double? price,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}

class SaleItem {
  final Product product;
  int quantity;
  double get totalPrice => product.price * quantity;

  SaleItem({
    required this.product,
    this.quantity = 1,
  });
}