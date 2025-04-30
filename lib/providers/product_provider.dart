import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final _uuid = const Uuid();

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;

  void addProduct(String name, double basePrice, double gstRate) {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      basePrice: basePrice,
      gstRate: gstRate,
    );
    _products.add(product);
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
      _filteredProducts = List.from(_products);
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((product) => product.id == id);
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
