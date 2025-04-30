import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import 'transaction_provider.dart';

class CartProvider with ChangeNotifier {
  final List<InvoiceItem> _items = [];
  final _uuid = const Uuid();

  List<InvoiceItem> get items => _items;

  void addItem(Product product, {int quantity = 1}) {
    _items.add(InvoiceItem(
      id: _uuid.v4(),
      product: product,
      quantity: quantity,
    ));
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<Invoice> generateInvoice(BuildContext context) async {
    final invoice = Invoice(items: List.from(_items));
    if (context.mounted) {
      await Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(invoice);
    }
    clearCart();
    return invoice;
  }

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalAmount);
}
