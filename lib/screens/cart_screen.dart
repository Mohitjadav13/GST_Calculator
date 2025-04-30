import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'invoice_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () async {
              final cartProvider = context.read<CartProvider>();
              if (cartProvider.items.isNotEmpty) {
                final invoice = await cartProvider.generateInvoice(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceScreen(invoice: invoice),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return ListView.builder(
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return ListTile(
                title: Text(item.product.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Base Price: ${item.product.formattedBasePrice}'),
                    Text('GST Rate: ${item.product.gstRate}%'),
                    Text('Quantity: ${item.quantity}'),
                    Text('Total: ₹${item.totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () => cartProvider.removeItem(item.id),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) return const SizedBox.shrink();
          
          return Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: cartProvider.items.isEmpty ? null : () async {
                    final invoice = await cartProvider.generateInvoice(context);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceScreen(invoice: invoice),
                        ),
                      );
                    }
                  },
                  child: const Text('Generate Invoice'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
