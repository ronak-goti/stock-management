import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/product.dart';  // Ensure this path matches your project structure

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('products');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        products = decoded.map((e) => Product.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString('products', encoded);
  }

  void increaseStock(int index) {
    setState(() {
      products[index] = Product(
        name: products[index].name,
        sku: products[index].sku,
        barcode: products[index].barcode,
        costPrice: products[index].costPrice,
        sellingPrice: products[index].sellingPrice,
        quantity: products[index].quantity + 1,
        category: products[index].category,
        image: products[index].image,
      );
    });
    _saveProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock increased successfully!')),
    );
  }

  void decreaseStock(int index) {
    if (products[index].quantity > 0) {
      setState(() {
        products[index] = Product(
          name: products[index].name,
          sku: products[index].sku,
          barcode: products[index].barcode,
          costPrice: products[index].costPrice,
          sellingPrice: products[index].sellingPrice,
          quantity: products[index].quantity - 1,
          category: products[index].category,
          image: products[index].image,
        );
      });
      _saveProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock decreased successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot decrease stock below 0')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Inventory'),
      ),
      body: products.isEmpty
          ? const Center(
        child: Text("No products added yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final p = products[i];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: p.image != null ? FileImage(p.image!) : null,
                child: p.image == null ? const Icon(Icons.inventory) : null,
              ),
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Quantity: ${p.quantity} | SKU: ${p.sku}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => decreaseStock(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => increaseStock(i),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}