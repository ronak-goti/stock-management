import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bill.dart';

class BillAddRemoveScreen extends StatefulWidget {
  const BillAddRemoveScreen({super.key});

  @override
  State<BillAddRemoveScreen> createState() => _BillAddRemoveScreenState();
}

class _BillAddRemoveScreenState extends State<BillAddRemoveScreen> {
  List<Bill> bills = [];

  final _formKey = GlobalKey<FormState>();
  final _billNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('bills');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      setState(() {
        bills = decoded.map((e) => Bill.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveBills() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bills', jsonEncode(bills.map((b) => b.toJson()).toList()));
  }

  void _addBill() {
    if (!_formKey.currentState!.validate()) return;

    final bill = Bill(
      billNumber: _billNumberController.text.trim(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: DateTime.now().toString().split(' ')[0],
    );

    setState(() {
      bills.add(bill);
      _clearForm();
    });

    _saveBills();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill added successfully!')),
    );
  }

  void _clearForm() {
    _billNumberController.clear();
    _nameController.clear();
    _amountController.clear();
  }

  void _editBill(int index) {
    final bill = bills[index];
    _billNumberController.text = bill.billNumber;
    _nameController.text = bill.name;
    _amountController.text = bill.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bill"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_billNumberController, "Bill Number", isNumber: true),
              _buildTextField(_nameController, "Customer Name"),
              _buildTextField(_amountController, "Amount", isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_billNumberController.text.isEmpty ||
                  _nameController.text.isEmpty ||
                  _amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

              final amount = double.tryParse(_amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid positive amount")),
                );
                return;
              }

              setState(() {
                bills[index] = Bill(
                  billNumber: _billNumberController.text.trim(),
                  name: _nameController.text.trim(),
                  amount: amount,
                  date: bill.date,
                );
              });

              _saveBills();
              Navigator.pop(context);
              _clearForm();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bill updated successfully!")),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteBill(int index) {
    setState(() => bills.removeAt(index));
    _saveBills();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bill deleted successfully!")),
    );
  }

  void _deleteAllBills() {
    setState(() => bills.clear());
    _saveBills();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All bills deleted successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bill Management"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 3,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth < 400 ? 8.0 : 16.0;
            return Padding(
              padding: EdgeInsets.all(padding),
              child: isWide
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFormCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: _buildBillList()),
                ],
              )
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    _buildBillList(),
                  ],
                ),
              ),
            );
          },
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add / Edit Bill",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildTextField(_billNumberController, "Bill Number", isNumber: true),
              _buildTextField(_nameController, "Customer Name"),
              _buildTextField(_amountController, "Amount", isNumber: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addBill,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Bill"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillList() {
    if (bills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(
          child: Text(
            "No bills added yet.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Bills List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _deleteAllBills,
              icon: const Icon(Icons.delete_forever),
              label: const Text("Delete All"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            final bill = bills[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                  "Bill ${bill.billNumber} - ${bill.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "₹${bill.amount.toStringAsFixed(2)} | Date: ${bill.date}",
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _editBill(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBill(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (isNumber && double.tryParse(value.trim()) == null) {
            return 'Enter valid number';
          }
          return null;
        },
      ),
    );
  }
}
