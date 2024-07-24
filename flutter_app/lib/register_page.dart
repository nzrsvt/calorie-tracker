import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _activityLevel = 'S';
  String _goal = 'L';

  void _register() async {
    try {
      await _authService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _genderController.text,
        int.parse(_ageController.text),
        int.parse(_heightController.text),
        double.parse(_weightController.text),
        _activityLevel,
        _goal,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to register')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender (M/F)'),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: _activityLevel,
                items: const [
                  DropdownMenuItem(value: 'S', child: Text('Sedentary')),
                  DropdownMenuItem(value: 'L', child: Text('Lightly active')),
                  DropdownMenuItem(value: 'M', child: Text('Moderately active')),
                  DropdownMenuItem(value: 'V', child: Text('Very active')),
                  DropdownMenuItem(value: 'E', child: Text('Extra active')),
                ],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
              ),
              DropdownButton<String>(
                value: _goal,
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Weight loss')),
                  DropdownMenuItem(value: 'M', child: Text('Weight maintenance')),
                  DropdownMenuItem(value: 'G', child: Text('Weight gain')),
                ],
                onChanged: (value) {
                  setState(() {
                    _goal = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
