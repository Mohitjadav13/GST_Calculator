import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/invoice.dart';
import 'invoice_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String? _searchQuery;
  DateTime? _selectedDate;
  String _searchType = 'text'; // 'text' or 'date'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchType == 'date') {
        _showDatePicker();
      }
    });
  }

  Future<void> _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _searchQuery = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: _searchType == 'date' 
                        ? 'Select Date' 
                        : 'Search by Invoice ID or Product Name',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  controller: _searchType == 'date' 
                      ? TextEditingController(text: _searchQuery)
                      : null,
                  onChanged: _searchType == 'date' ? null : (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  readOnly: _searchType == 'date',
                  onTap: _searchType == 'date' ? _showDatePicker : null,
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'text',
                    icon: Icon(Icons.text_fields),
                  ),
                  ButtonSegment(
                    value: 'date',
                    icon: Icon(Icons.calendar_today),
                  ),
                ],
                selected: {_searchType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _searchType = newSelection.first;
                    _searchQuery = null;
                    _selectedDate = null;
                    if (_searchType == 'date') {
                      _showDatePicker();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              List<Invoice> transactions = (_searchQuery?.isNotEmpty ?? false)
                  ? provider.searchTransactions(
                      invoiceId: _searchType == 'text' ? _searchQuery : null,
                      date: _selectedDate,
                      productName: _searchType == 'text' ? _searchQuery : null,
                    )
                  : provider.transactions;

              if (transactions.isEmpty) {
                return const Center(
                  child: Text('No transactions found'),
                );
              }

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final invoice = transactions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceScreen(
                              invoice: invoice,
                              currentIndex: 1, // Keep history tab selected
                            ),
                            fullscreenDialog: true, // Add this
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Invoice #${invoice.id.substring(0, 8)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm').format(invoice.date),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InvoiceScreen(invoice: invoice),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                            Text('Items: ${invoice.items.length}'),
                            const SizedBox(height: 4),
                            ...invoice.items.take(3).map((item) => Text(
                              '• ${item.quantity}x ${item.product.name}',
                              style: TextStyle(color: Colors.grey[600]),
                            )),
                            if (invoice.items.length > 3)
                              Text(
                                'and ${invoice.items.length - 3} more...',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Base: ₹${invoice.totalBasePrice.toStringAsFixed(2)}'),
                                    Text('GST: ₹${(invoice.totalCGST + invoice.totalSGST).toStringAsFixed(2)}'),
                                  ],
                                ),
                                Text(
                                  'Total: ₹${invoice.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
