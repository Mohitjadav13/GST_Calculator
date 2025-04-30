import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  double _selectedGstRate = 5.0;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return cart.items.isEmpty
                        ? const SizedBox()
                        : Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.items.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildProductList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search Products',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          Provider.of<ProductProvider>(context, listen: false)
              .searchProducts(value);
        },
      ),
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return ListView.builder(
            itemCount: productProvider.filteredProducts.length,
            itemBuilder: (context, index) {
              final product = productProvider.filteredProducts[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Base Price: ${product.formattedBasePrice}'),
                          Text('GST Rate: ${product.gstRate}%'),
                          Text('CGST (${product.gstRate/2}%): ${product.formattedCGST}'),
                          Text('SGST (${product.gstRate/2}%): ${product.formattedSGST}'),
                          Text('Total Price: ${product.formattedTotalPrice}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Container(
                        width: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditProductDialog(context, product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteProduct(product.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddToCartDialog(context, product),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: _buildProductForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _saveProduct(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    _nameController.text = product.name;
    _priceController.text = product.basePrice.toString();
    _selectedGstRate = product.gstRate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: _buildProductForm(isEditing: true, product: product),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _updateProduct(context, product),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductForm({bool isEditing = false, Product? product}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Product Name'),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a name' : null,
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Base Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              // Try parsing the value as double
              try {
                final price = double.parse(value);
                if (price <= 0) {
                  return 'Price must be greater than 0';
                }
              } catch (e) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          DropdownButtonFormField<double>(
            value: _selectedGstRate,
            items: const [
              DropdownMenuItem(value: 5.0, child: Text('5%')),
              DropdownMenuItem(value: 12.0, child: Text('12%')),
              DropdownMenuItem(value: 18.0, child: Text('18%')),
              DropdownMenuItem(value: 28.0, child: Text('28%')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGstRate = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'GST Rate'),
          ),
        ],
      ),
    );
  }

  void _saveProduct(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final name = _nameController.text;
        final price = double.parse(_priceController.text);
        
        Provider.of<ProductProvider>(context, listen: false)
            .addProduct(name, price, _selectedGstRate)
            .then((_) {
          _clearForm();
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid price format'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateProduct(BuildContext context, Product product) {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updatedProduct = Product(
          id: product.id,
          name: _nameController.text,
          basePrice: double.parse(_priceController.text),
          gstRate: _selectedGstRate,
        );

        Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(updatedProduct)
            .then((_) {
          _clearForm();
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid price format'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteProduct(String id) {
    Provider.of<ProductProvider>(context, listen: false)
        .deleteProduct(id);
  }

  void _showAddToCartDialog(BuildContext context, Product product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add to Cart'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product: ${product.name}'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => quantity++);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartProvider>().addItem(product, quantity: quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _selectedGstRate = 5.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
