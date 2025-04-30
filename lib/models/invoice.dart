import 'package:uuid/uuid.dart';
import 'invoice_item.dart';

class Invoice {
  final String id;
  final List<InvoiceItem> items;
  final DateTime date;

  Invoice({
    String? id,
    required this.items,
    DateTime? date,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalAmount);
  double get totalCGST => items.fold(0, (sum, item) => sum + item.totalCGST);
  double get totalSGST => items.fold(0, (sum, item) => sum + item.totalSGST);
  double get totalBasePrice => items.fold(0, (sum, item) => sum + item.totalBasePrice);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
    );
  }
}
