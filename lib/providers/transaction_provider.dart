import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/invoice.dart';

class TransactionProvider with ChangeNotifier {
  List<Invoice> _transactions = [];
  static const String _storageKey = 'transactions';

  List<Invoice> get transactions => _transactions;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _transactions = decoded.map((json) => Invoice.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<void> addTransaction(Invoice invoice) async {
    _transactions.insert(0, invoice); // Add new transactions at the beginning
    await _saveTransactions();
    notifyListeners();
  }

  List<Invoice> searchTransactions({
    String? invoiceId,
    DateTime? date,
    String? productName,
  }) {
    return _transactions.where((invoice) {
      if (invoiceId != null && invoice.id.toLowerCase().contains(invoiceId.toLowerCase())) {
        return true;
      }
      if (date != null && _isSameDay(invoice.date, date)) {
        return true;
      }
      if (productName != null) {
        return invoice.items.any((item) =>
            item.product.name.toLowerCase().contains(productName.toLowerCase()));
      }
      return false;
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
