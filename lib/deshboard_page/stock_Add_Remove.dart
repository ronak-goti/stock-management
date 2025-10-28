import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';

class StockAddRemoveScreen extends StatefulWidget {
  const StockAddRemoveScreen({super.key});

  @override
  State<StockAddRemoveScreen> createState() => _StockAddRemoveScreenState();
}

class _StockAddRemoveScreenState extends State<StockAddRemoveScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  List<Product> products = [];
  List<Product> filteredProducts = [];
  File? _selectedImage;
  String? _webImage;

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();

  // Search & filter
  final _searchController = TextEditingController();
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('products');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      setState(() {
        products = decoded.map((e) => Product.fromJson(e)).toList();
        filteredProducts = List.from(products);
      });
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'products', jsonEncode(products.map((e) => e.toJson()).toList()));
    _filterProducts(); // refresh filtered list
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _webImage = base64Encode(bytes));
      } else {
        setState(() => _selectedImage = File(picked.path));
      }
    }
  }

  void _addProduct() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      barcode: _barcodeController.text.trim(),
      costPrice: double.parse(_costController.text.trim()),
      sellingPrice: double.parse(_priceController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),
      category: _categoryController.text.trim(),
      image: _selectedImage,
      webImage: _webImage,
    );

    setState(() {
      products.add(product);
      _clearForm();
    });
    _saveProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully!')),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _skuController.clear();
    _barcodeController.clear();
    _costController.clear();
    _priceController.clear();
    _quantityController.clear();
    _categoryController.clear();
    _selectedImage = null;
    _webImage = null;
  }

  void _editProduct(int index) {
    final p = filteredProducts[index];
    final originalIndex = products.indexOf(p);

    _nameController.text = p.name;
    _skuController.text = p.sku;
    _barcodeController.text = p.barcode;
    _costController.text = p.costPrice.toString();
    _priceController.text = p.sellingPrice.toString();
    _quantityController.text = p.quantity.toString();
    _categoryController.text = p.category;
    _selectedImage = p.image;
    _webImage = p.webImage;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, "Product Name"),
              _buildTextField(_skuController, "SKU"),
              _buildTextField(_barcodeController, "Barcode", isBarcode: true),
              _buildTextField(_costController, "Cost Price", isNumber: true),
              _buildTextField(_priceController, "Selling Price", isNumber: true),
              _buildTextField(_quantityController, "Quantity", isNumber: true),
              _buildTextField(_categoryController, "Category"),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              setState(() {
                products[originalIndex] = Product(
                  name: _nameController.text.trim(),
                  sku: _skuController.text.trim(),
                  barcode: _barcodeController.text.trim(),
                  costPrice: double.parse(_costController.text.trim()),
                  sellingPrice: double.parse(_priceController.text.trim()),
                  quantity: int.parse(_quantityController.text.trim()),
                  category: _categoryController.text.trim(),
                  image: _selectedImage,
                  webImage: _webImage,
                );
              });

              _saveProducts();
              _clearForm();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product updated successfully!')),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(int index) {
    final p = filteredProducts[index];
    setState(() {
      products.remove(p);
    });
    _saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully!')),
    );
  }

  void _deleteAll() {
    setState(() {
      products.clear();
      filteredProducts.clear();
    });
    _saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All products deleted!')),
    );
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    final category = _selectedCategory;

    setState(() {
      filteredProducts = products.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(query) ||
            p.sku.toLowerCase().contains(query);
        final matchesCategory =
            category == "All" || p.category.toLowerCase() == category.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    final allCategories = products.map((p) => p.category).toSet().toList();
    allCategories.sort();
    return ["All", ...allCategories];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Stock Management"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isWide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildFormCard()),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildProductSection()),
            ],
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                _buildFormCard(),
                const SizedBox(height: 20),
                _buildProductSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Add / Edit Product",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: kIsWeb
                        ? (_webImage != null
                        ? MemoryImage(base64Decode(_webImage!))
                        : null)
                        : (_selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null),
                    child: (_selectedImage == null && _webImage == null)
                        ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Product Name"),
                _buildTextField(_skuController, "SKU"),
                _buildTextField(_barcodeController, "Barcode", isBarcode: true),
                _buildTextField(_costController, "Cost Price", isNumber: true),
                _buildTextField(_priceController, "Selling Price", isNumber: true),
                _buildTextField(_quantityController, "Quantity", isNumber: true),
                _buildTextField(_categoryController, "Category"),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Product"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔍 Search + Filter Row
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by name or SKU...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val!);
                  _filterProducts();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  labelText: "Category",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        filteredProducts.isEmpty
            ? const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text("No products found.",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
        )
            : Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Product List",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _deleteAll,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Delete All"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                MediaQuery.of(context).size.width > 800 ? 2 : 1,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: kIsWeb
                          ? (p.webImage != null
                          ? MemoryImage(base64Decode(p.webImage!))
                          : null)
                          : (p.image != null
                          ? FileImage(p.image!)
                          : null),
                      child: (p.image == null && p.webImage == null)
                          ? const Icon(Icons.inventory)
                          : null,
                    ),
                    title: Text(p.name,
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "SKU: ${p.sku}\nQty: ${p.quantity} | ₹${p.sellingPrice}"),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            onPressed: () => _editProduct(index)),
                        IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => _deleteProduct(index)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false, bool isBarcode = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isBarcode
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12)
        ]
            : isNumber
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (isBarcode &&
              (value.length != 12 || !RegExp(r'^\d{12}$').hasMatch(value))) {
            return 'Barcode must be 12 digits';
          }
          if (isNumber && double.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
