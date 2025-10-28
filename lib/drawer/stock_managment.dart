import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/product.dart';  // Ensure this path matches your project structure

class Stock_management extends StatefulWidget {
  const Stock_management({super.key});

  @override
  State<Stock_management> createState() => _Stock_managementState();
}

class _Stock_managementState extends State<Stock_management> {
  List<Product> products = [];
  List<Product> lowStockProducts = [];

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
        lowStockProducts = products.where((p) => p.quantity <= 5).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Low Stock Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: lowStockProducts.isEmpty
                  ? const Center(child: Text("No low stock items"))
                  : ListView.builder(
                itemCount: lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(product.name),
                      subtitle: Text("Quantity: ${product.quantity}"),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to a full low stock view screen (implement separately)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("View All Low Stock Products")),
                );
              },
              child: const Text("View All Low Stock Products"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Low Stock Alerts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // For alerts, display similar list; add push notifications logic if needed
            Expanded(
              child: lowStockProducts.isEmpty
                  ? const Center(child: Text("No alerts"))
                  : ListView.builder(
                itemCount: lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text("⚠️ ${product.name} is below minimum stock (only ${product.quantity} left)."),
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