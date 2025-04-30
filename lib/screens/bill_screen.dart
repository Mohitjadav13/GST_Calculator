import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../models/invoice_item.dart';  // Add this import
import 'invoice_screen.dart';
import 'transaction_history_screen.dart';
import '../state/bill_screen_state.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  double _selectedGstRate = 5.0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillScreenState(),
      child: Consumer<BillScreenState>(
        builder: (context, state, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.currentIndex == 0 ? 'New Bill' : 'History'),
              automaticallyImplyLeading: false,
            ),
            body: Stack(
              children: [
                // Main content
                state.currentIndex == 0 
                    ? _buildBillScreen() 
                    : const TransactionHistoryScreen(),
                    
                // Bottom container for cart info
                if (state.currentIndex == 0) 
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        if (cartProvider.items.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Items: ${cartProvider.items.length}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Grand Total: ₹${cartProvider.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final invoice = await cartProvider.generateInvoice(context);
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InvoiceScreen(
                                          invoice: invoice,
                                          currentIndex: state.currentIndex,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: const Text('Generate Invoice'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            floatingActionButton: state.currentIndex == 0 
                ? FloatingActionButton.extended(
                    onPressed: () => _showAddItemDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  )
                : null,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.currentIndex,
              onTap: (index) {
                state.setCurrentIndex(index);
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
        },
      ),
    );
  }

  Widget _buildBillScreen() {
    return Column(
      children: [
        Expanded(
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.items.isEmpty) {
                return const Center(
                  child: Text('No items added yet'),
                );
              }

              return ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final item = cartProvider.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editItem(context, item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => cartProvider.removeItem(item.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Base Price:'),
                              Text('₹${item.product.basePrice.toStringAsFixed(2)} × ${item.quantity}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('CGST (${item.product.gstRate/2}%):'),
                              Text('₹${item.totalCGST.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('SGST (${item.product.gstRate/2}%):'),
                              Text('₹${item.totalSGST.toStringAsFixed(2)}'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${item.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  void _showAddItemDialog() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.text = '1';
    _selectedGstRate = 5.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_shopping_cart, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Add Product'),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Base Price',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  if (double.parse(value) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _selectedGstRate,
                decoration: const InputDecoration(
                  labelText: 'GST Rate',
                  prefixIcon: Icon(Icons.percent),
                ),
                items: [5.0, 12.0, 18.0, 28.0].map((rate) {
                  return DropdownMenuItem(
                    value: rate,
                    child: Text('$rate%'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGstRate = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a whole number';
                  if (int.parse(value) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', 
              style: TextStyle(color: Colors.grey[600])
            ),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final product = Product(
                  id: DateTime.now().toString(),
                  name: _nameController.text,
                  basePrice: double.parse(_priceController.text),
                  gstRate: _selectedGstRate,
                );
                context.read<CartProvider>().addItem(
                  product,
                  quantity: int.parse(_quantityController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No items to edit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Item to Edit'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return ListTile(
                title: Text(item.product.name),
                subtitle: Text('Quantity: ${item.quantity}'),
                onTap: () {
                  Navigator.pop(context);
                  _editItem(context, item);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _editItem(BuildContext context, InvoiceItem item) {
    _nameController.text = item.product.name;
    _priceController.text = item.product.basePrice.toString();
    _selectedGstRate = item.product.gstRate;
    _quantityController.text = item.quantity.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Base Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  if (double.parse(value) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
              DropdownButtonFormField<double>(
                value: _selectedGstRate,
                decoration: const InputDecoration(labelText: 'GST Rate'),
                items: [5.0, 12.0, 18.0, 28.0].map((rate) {
                  return DropdownMenuItem(
                    value: rate,
                    child: Text('$rate%'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGstRate = value!;
                  });
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a whole number';
                  if (int.parse(value) <= 0) return 'Must be greater than 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final updatedProduct = Product(
                  id: item.product.id,
                  name: _nameController.text,
                  basePrice: double.parse(_priceController.text),
                  gstRate: _selectedGstRate,
                );
                
                context.read<CartProvider>().removeItem(item.id);
                context.read<CartProvider>().addItem(
                  updatedProduct,
                  quantity: int.parse(_quantityController.text),
                );
                
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
