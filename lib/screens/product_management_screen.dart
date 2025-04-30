import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

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
                child: ListTile(
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
                  trailing: Row(
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
            keyboardType: TextInputType.number,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a price' : null,
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
      final name = _nameController.text;
      final price = double.parse(_priceController.text);
      
      Provider.of<ProductProvider>(context, listen: false)
          .addProduct(name, price, _selectedGstRate);

      _clearForm();
      Navigator.pop(context);
    }
  }

  void _updateProduct(BuildContext context, Product product) {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProduct = Product(
        id: product.id,
        name: _nameController.text,
        basePrice: double.parse(_priceController.text),
        gstRate: _selectedGstRate,
      );

      Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(updatedProduct);

      _clearForm();
      Navigator.pop(context);
    }
  }

  void _deleteProduct(String id) {
    Provider.of<ProductProvider>(context, listen: false).deleteProduct(id);
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
