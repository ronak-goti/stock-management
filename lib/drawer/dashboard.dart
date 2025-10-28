import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/bill.dart';  // Ensure this path matches your project structure

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Bill> bills = [];
  double todaysSales = 0.0;
  int todaysOrders = 0;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('bills');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        bills = decoded.map((e) => Bill.fromJson(e)).toList();
        _calculateTodaysSales();
      });
    }
  }

  void _calculateTodaysSales() {
    final today = DateTime.now().toString().split(' ')[0];  // YYYY-MM-DD format
    final todaysBills = bills.where((bill) => bill.date == today).toList();
    todaysSales = todaysBills.fold(0.0, (sum, bill) => sum + bill.amount);
    todaysOrders = todaysBills.length;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Snapshot",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Today’s Sales: ₹${todaysSales.toStringAsFixed(2)} | $todaysOrders Orders Today",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}