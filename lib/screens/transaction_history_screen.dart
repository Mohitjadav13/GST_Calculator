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
  String _searchType = 'id';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = null;
                  _selectedDate = null;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search ${_searchType == 'id' ? 'Invoice ID' : _searchType == 'date' ? 'Select Date' : 'Product Name'}',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      readOnly: _searchType == 'date',
                      onTap: _searchType == 'date' ? () async {
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
                      } : null,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (value) {
                      setState(() {
                        _searchType = value;
                        _searchQuery = null;
                        _selectedDate = null;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'id', child: Text('Search by ID')),
                      const PopupMenuItem(value: 'date', child: Text('Search by Date')),
                      const PopupMenuItem(value: 'product', child: Text('Search by Product')),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                List<Invoice> transactions = _isSearching && (_searchQuery?.isNotEmpty ?? false)
                    ? provider.searchTransactions(
                        invoiceId: _searchType == 'id' ? _searchQuery : null,
                        date: _selectedDate,
                        productName: _searchType == 'product' ? _searchQuery : null,
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
                      child: ListTile(
                        title: Text(
                          'Invoice #${invoice.id.substring(0, 8)}...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${DateFormat('dd/MM/yyyy').format(invoice.date)}'),
                            Text('Items: ${invoice.items.length}'),
                            Text(
                              'Total: ₹${invoice.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceScreen(invoice: invoice),
                            ),
                          );
                        },
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
