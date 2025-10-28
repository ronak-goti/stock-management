import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString("name") ?? "";
      _emailController.text = prefs.getString("email") ?? "";
      _phoneController.text = prefs.getString("phone") ?? "";
    });
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", _nameController.text.trim());
    await prefs.setString("email", _emailController.text.trim());
    await prefs.setString("phone", _phoneController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Info")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, "Full Name", Icons.person),
              _buildField(_emailController, "Email", Icons.email,
                  keyboardType: TextInputType.emailAddress),
              _buildField(_phoneController, "Phone", Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14),
                ),
                onPressed: _saveUserData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter your $label";
          }
          return null;
        },
      ),
    );
  }
}
