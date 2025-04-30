class Product {
  String id;
  String name;
  double basePrice;
  double gstRate;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.gstRate,
  });

  // GST calculations
  double get cgst => (basePrice * gstRate / 100) / 2;
  double get sgst => (basePrice * gstRate / 100) / 2;
  double get totalGst => cgst + sgst;
  double get totalPrice => basePrice + totalGst;

  // Format currency values
  String get formattedBasePrice => '₹${basePrice.toStringAsFixed(2)}';
  String get formattedCGST => '₹${cgst.toStringAsFixed(2)}';
  String get formattedSGST => '₹${sgst.toStringAsFixed(2)}';
  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'gstRate': gstRate,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      basePrice: map['basePrice'],
      gstRate: map['gstRate'],
    );
  }
}
