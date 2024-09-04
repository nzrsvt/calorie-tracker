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
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _gender = 'M';
  String _activityLevel = 'S';
  String _goal = 'L';
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        context,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _gender,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to register'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showActivityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Level Info'),
        content: const Text(
            '• Sedentary - little or no exercise\n'
            '• Lightly active - light exercise/sports 1-3 days/week\n'
            '• Moderately active - moderate exercise/sports 3-5 days/week\n'
            '• Very active - hard exercise/sports 6-7 days a week\n'
            '• Extra active - very hard exercise, physical job or training twice a day'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(_usernameController, 'Username', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 16),
              _buildDropdown(
                'Gender',
                _gender,
                {
                  'M': 'Male',
                  'F': 'Female',
                },
                (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(_ageController, 'Age', Icons.cake, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_heightController, 'Height (cm)', Icons.height, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_weightController, 'Weight (kg)', Icons.fitness_center, isNumber: true),
              const SizedBox(height: 24),
              _buildDropdownWithInfoIcon(
                'Activity Level',
                _activityLevel,
                {
                  'S': 'Sedentary',
                  'L': 'Lightly active',
                  'M': 'Moderately active',
                  'V': 'Very active',
                  'E': 'Extra active',
                },
                (value) => setState(() => _activityLevel = value!),
                _showActivityInfo,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Goal',
                _goal,
                {
                  'L': 'Weight loss',
                  'M': 'Weight maintenance',
                  'G': 'Weight gain',
                },
                (value) => setState(() => _goal = value!),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildDropdown(String label, String value, Map<String, String> items, void Function(String?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownWithInfoIcon(String label, String value, Map<String, String> items, void Function(String?) onChanged, void Function() onInfoPressed) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                isExpanded: true,
                items: items.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onInfoPressed,
          ),
        ],
      ),
    );
  }
}
