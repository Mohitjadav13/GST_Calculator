import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final _uuid = const Uuid();
  static const String _storageKey = 'products';

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;

  ProductProvider() {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsJson = prefs.getString(_storageKey);
    
    if (productsJson != null) {
      final List<dynamic> decoded = jsonDecode(productsJson);
      _products.clear();
      _products.addAll(
        decoded.map((item) => Product(
          id: item['id'],
          name: item['name'],
          basePrice: item['basePrice'].toDouble(),
          gstRate: item['gstRate'].toDouble(),
        )),
      );
      _filteredProducts = List.from(_products);
      notifyListeners();
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_products.map((product) => {
      'id': product.id,
      'name': product.name,
      'basePrice': product.basePrice,
      'gstRate': product.gstRate,
    }).toList());
    
    await prefs.setString(_storageKey, encodedData);
  }

  Future<void> addProduct(String name, double basePrice, double gstRate) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      basePrice: basePrice,
      gstRate: gstRate,
    );
    _products.add(product);
    _filteredProducts = List.from(_products);
    notifyListeners();
    await _saveProducts();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
      _filteredProducts = List.from(_products);
      notifyListeners();
      await _saveProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((product) => product.id == id);
    _filteredProducts = List.from(_products);
    notifyListeners();
    await _saveProducts();
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
