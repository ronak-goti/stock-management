import 'package:flutter/material.dart';

class StockReminder extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {'name': 'Product A', 'quantity': 2},
    {'name': 'Product B', 'quantity': 4},
    {'name': 'Product C', 'quantity': 10},
  ];

  StockReminder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lowStock = products.where((p) => p['quantity'] <= 5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Reminder')),
      body: lowStock.isEmpty
          ? const Center(child: Text('All products have sufficient stock.'))
          : ListView.builder(
        itemCount: lowStock.length,
        itemBuilder: (ctx, i) {
          final p = lowStock[i];
          return ListTile(
            title: Text(p['name']),
            trailing: Text('Qty: ${p['quantity']}'),
          );
        },
      ),
    );
  }
}
