import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usersBox = Hive.box('users');

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSignup = false;

  void _toggleMode() {
    setState(() {
      _isSignup = !_isSignup;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSignup) {
      if (_usersBox.containsKey(username)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Username already exists")));
        return;
      }
      _usersBox.put(username, {
        'password': password,
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Signup successful. Please login.")));
      setState(() => _isSignup = false);
      return;
    }

    if (!_usersBox.containsKey(username) ||
        _usersBox.get(username)['password'] != password) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid username or password")));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(currentUser: username),
      ),
    );
  }

  InputDecoration _label(String text, {bool required = false}) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: required
              ? [
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                ]
              : [],
        ),
      ),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(_isSignup ? "Sign Up" : "Login",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                if (_isSignup) ...[
                  TextFormField(
                    controller: _firstNameController,
                    decoration: _label("First Name", required: true),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _middleNameController,
                    decoration: _label("Middle Name"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: _label("Last Name", required: true),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _usernameController,
                  decoration: _label("Username", required: true),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _label("Password", required: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Required";
                    if (v.replaceAll(" ", "").length < 8) return "Minimum 8 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black),
                  child: Text(_isSignup ? "Sign Up" : "Login"),
                ),
                TextButton(
                    onPressed: _toggleMode,
                    child: Text(_isSignup
                        ? "Already have an account? Login"
                        : "Don't have an account? Sign Up")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
  