import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../model/customer.dart';  // Ensure this path matches your project structure
import '../model/bill.dart';  // For calculating top customer

class Drawer_customer extends StatefulWidget {
  const Drawer_customer({super.key});

  @override
  State<Drawer_customer> createState() => _Drawer_customerState();
}

class _Drawer_customerState extends State<Drawer_customer> {
  List<Customer> customers = [];
  List<Bill> bills = [];
  String topCustomer = "None";
  double topAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerString = prefs.getString('customers');
    final billString = prefs.getString('bills');
    if (customerString != null) {
      final List<dynamic> decoded = jsonDecode(customerString);
      customers = decoded.map((e) => Customer.fromJson(e)).toList();
    }
    if (billString != null) {
      final List<dynamic> decoded = jsonDecode(billString);
      bills = decoded.map((e) => Bill.fromJson(e)).toList();
    }
    _calculateTopCustomer();
    setState(() {});
  }

  void _calculateTopCustomer() {
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final monthlyBills = bills.where((b) => b.date.startsWith(currentMonth)).toList();
    final Map<String, double> customerTotals = {};
    for (var bill in monthlyBills) {
      customerTotals[bill.name] = (customerTotals[bill.name] ?? 0) + bill.amount;
    }
    if (customerTotals.isNotEmpty) {
      final top = customerTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      topCustomer = top.key;
      topAmount = top.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Top Customer This Month: $topCustomer | ₹${topAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Quick Contact",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Card(
                    child: ListTile(
                      title: Text(customer.name),
                      subtitle: Text(customer.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.green),
                            onPressed: () async {
                              final url = "https://wa.me/${customer.phone}";
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.email, color: Colors.blue),
                            onPressed: () async {
                              final url = "mailto:${customer.email}";
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                          ),
                        ],
                      ),
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