import 'package:uuid/uuid.dart';
import 'product.dart';

class InvoiceItem {
  final String id;
  final Product product;
  final int quantity;

  InvoiceItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalBasePrice => product.basePrice * quantity;
  double get totalCGST => product.cgst * quantity;
  double get totalSGST => product.sgst * quantity;
  double get totalAmount => product.totalPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}
