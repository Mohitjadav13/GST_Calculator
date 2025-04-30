import 'package:flutter/material.dart';
import '../models/invoice.dart';
import 'package:intl/intl.dart';
import 'bill_screen.dart';
import 'package:provider/provider.dart';
import '../state/bill_screen_state.dart';

class InvoiceScreen extends StatelessWidget {
  final Invoice invoice;
  final int currentIndex;

  const InvoiceScreen({
    super.key, 
    required this.invoice,
    this.currentIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Changed to simple pop
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice #${invoice.id}'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(invoice.date)}'),
            const SizedBox(height: 20),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoice.items.length,
              itemBuilder: (context, index) {
                final item = invoice.items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name),
                        Text('Base Price: ${item.product.formattedBasePrice} × ${item.quantity}'),
                        Text('GST Rate: ${item.product.gstRate}%'),
                        Text('CGST: ${item.totalCGST.toStringAsFixed(2)}'),
                        Text('SGST: ${item.totalSGST.toStringAsFixed(2)}'),
                        Text('Total: ₹${item.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Base Amount: ₹${invoice.totalBasePrice.toStringAsFixed(2)}'),
                    Text('Total CGST: ₹${invoice.totalCGST.toStringAsFixed(2)}'),
                    Text('Total SGST: ₹${invoice.totalSGST.toStringAsFixed(2)}'),
                    const Divider(),
                    Text(
                      'Grand Total: ₹${invoice.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const BillScreen(),
              ),
              (route) => false,
            );
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                context.read<BillScreenState>().setCurrentIndex(index);
              }
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
