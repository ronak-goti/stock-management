import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/product.dart';  // Ensure this path matches your project structure

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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

  @override
  Widget build(BuildContext context) {
    final lowStockProducts = products.where((p) => p.quantity <= 5).toList();
    final totalProducts = products.length;
    final lowStockCount = lowStockProducts.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Report')),
      body: products.isEmpty
          ? const Center(
        child: Text("No products added yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Summary Section
            Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Total Products: $totalProducts', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Low Stock Items: $lowStockCount', style: TextStyle(fontSize: 16, color: lowStockCount > 0 ? Colors.red : Colors.green)),
                  ],
                ),
              ),
            ),
            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  final p = products[i];
                  final isLowStock = p.quantity <= 5;
                  final lastUpdated = DateTime.now().toString().split(' ')[0];  // Placeholder; use actual update time in real app

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: p.image != null ? FileImage(p.image!) : null,
                        child: p.image == null ? const Icon(Icons.inventory) : null,
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Quantity: ${p.quantity}\nLast Updated: $lastUpdated'),
                      trailing: isLowStock
                          ? const Icon(Icons.warning, color: Colors.red)
                          : const Icon(Icons.check, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}