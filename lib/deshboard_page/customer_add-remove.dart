import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/customer.dart';

class CustomerAddRemoveScreen extends StatefulWidget {
  const CustomerAddRemoveScreen({super.key});

  @override
  State<CustomerAddRemoveScreen> createState() => _CustomerAddRemoveScreenState();
}

class _CustomerAddRemoveScreenState extends State<CustomerAddRemoveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _webImage;
  List<Customer> customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('customers');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      setState(() {
        customers = decoded.map((e) => Customer.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customers', jsonEncode(customers.map((c) => c.toJson()).toList()));
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

  void _addCustomer() {
    if (!_formKey.currentState!.validate()) return;

    final newCustomer = Customer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      image: _selectedImage,
      webImage: _webImage,
    );

    setState(() {
      customers.add(newCustomer);
      _clearForm();
    });

    _saveCustomers();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer added successfully!')),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _selectedImage = null;
    _webImage = null;
  }

  void _editCustomer(int index) {
    final c = customers[index];
    _nameController.text = c.name;
    _phoneController.text = c.phone;
    _emailController.text = c.email;
    _selectedImage = c.image;
    _webImage = c.webImage;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Customer"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, "Customer Name"),
              _buildTextField(_phoneController, "Mobile Number", isPhone: true),
              _buildTextField(_emailController, "Email Address"),
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
              if (!_formKey.currentState!.validate()) return;

              setState(() {
                customers[index] = Customer(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  image: _selectedImage,
                  webImage: _webImage,
                );
              });

              _saveCustomers();
              _clearForm();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer updated successfully!')),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(int index) {
    setState(() => customers.removeAt(index));
    _saveCustomers();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Customer deleted successfully!')));
  }

  void _deleteAllCustomers() {
    setState(() => customers.clear());
    _saveCustomers();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('All customers deleted!')));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Management"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 3,
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
              Expanded(flex: 3, child: _buildCustomerList()),
            ],
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                _buildFormCard(),
                const SizedBox(height: 20),
                _buildCustomerList(),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Add / Edit Customer",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: kIsWeb
                      ? (_webImage != null ? MemoryImage(base64Decode(_webImage!)) : null)
                      : (_selectedImage != null ? FileImage(_selectedImage!) : null),
                  child: (_selectedImage == null && _webImage == null)
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, "Customer Name"),
              _buildTextField(_phoneController, "Mobile Number", isPhone: true),
              _buildTextField(_emailController, "Email Address"),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addCustomer,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Customer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            "No customers added yet.",
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
            const Text("Customer List",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: _deleteAllCustomers,
              icon: const Icon(Icons.delete_forever),
              label: const Text("Delete All"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final c = customers[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: kIsWeb
                      ? (c.webImage != null ? MemoryImage(base64Decode(c.webImage!)) : null)
                      : (c.image != null ? FileImage(c.image!) : null),
                  child: (c.image == null && c.webImage == null)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("📞 ${c.phone}\n✉️ ${c.email}"),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _editCustomer(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteCustomer(index),
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
      {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Please enter $label';
          if (isPhone && value.trim().length != 10) return 'Enter valid 10-digit number';
          if (label.contains("Email") && !value.contains('@')) return 'Enter valid email';
          return null;
        },
      ),
    );
  }
}
