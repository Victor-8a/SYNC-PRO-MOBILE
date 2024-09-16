import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';

class CartModel with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  double get total => _items.fold(0.0, (sum, item) => sum + item.precioFinal);

  void add(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity > 0) {
      final count = _items.where((p) => p == product).length;
      if (quantity > count) {
        for (var i = 0; i < quantity - count; i++) {
          _items.add(product);
        }
      } else {
        for (var i = 0; i < count - quantity; i++) {
          _items.remove(product);
        }
      }
      notifyListeners();
    } else {
      remove(product);
    }
  }
}
