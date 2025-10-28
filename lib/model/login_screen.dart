import 'package:flutter/material.dart';
import '../main_page.dart';
import 'signup_screen.dart';
import 'user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id == 'Admin123' && password == 'Admin@123') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainPage()));
      return;
    }

    final user = users.firstWhere(
          (u) => u.id == id && u.password == password,
      orElse: () => User(name: '', id: '', password: ''),
    );

    if (user.id.isNotEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ID or Password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.inventory, size: 80, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 25),

                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your ID' : null,
                  ),
                  const SizedBox(height: 15),

                  // 🔐 Password with show/hide icon
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your password' : null,
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text('Sign Up',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
