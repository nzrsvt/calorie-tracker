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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String? _gender;
  String? _activityLevel;
  String? _goal;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final Map<String, bool> _fieldsTouched = {};

  @override
  void initState() {
    super.initState();
    _gender = null;
    _activityLevel = null;
    _goal = null;
    _initFieldsTouched();
  }

  void _initFieldsTouched() {
    _fieldsTouched['Username'] = false;
    _fieldsTouched['Password'] = false;
    _fieldsTouched['Confirm Password'] = false;
    _fieldsTouched['Email'] = false;
    _fieldsTouched['Gender'] = false;
    _fieldsTouched['Age'] = false;
    _fieldsTouched['Height (cm)'] = false;
    _fieldsTouched['Weight (kg)'] = false;
    _fieldsTouched['Activity Level'] = false;
    _fieldsTouched['Goal'] = false;
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _areAllFieldsFilled() {
    return _fieldsTouched.values.every((value) => value) &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _gender != null &&
        _ageController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _activityLevel != null &&
        _goal != null;
  }

  void _register() async {
    setState(() {
      _fieldsTouched.updateAll((key, value) => true);
    });

    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        context,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _gender!,
        int.parse(_ageController.text),
        int.parse(_heightController.text),
        double.parse(_weightController.text),
        _activityLevel!,
        _goal!,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to register'),
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
          child: Form(
            key: _formKey,
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
                _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, isPassword: true),
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
                  (value) => setState(() => _gender = value),
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
                  (value) => setState(() => _activityLevel = value),
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
                  (value) => setState(() => _goal = value),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: (_isLoading || !_areAllFieldsFilled()) ? null : _register,
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return TextFormField(
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
      validator: (value) {
        if (!_fieldsTouched[label]!) {
          return null;
        }
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (isNumber) {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          if (label == 'Age') {
            int age = int.parse(value);
            if (age < 1 || age > 120) {
              return 'Please enter a valid age (1-120)';
            }
          }
          if (label == 'Height (cm)') {
            int height = int.parse(value);
            if (height < 50 || height > 300) {
              return 'Please enter a valid height (50-300 cm)';
            }
          }
          if (label == 'Weight (kg)') {
            double weight = double.parse(value);
            if (weight < 20 || weight > 500) {
              return 'Please enter a valid weight (20-500 kg)';
            }
          }
        }
        if (label == 'Email') {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        if (label == 'Password') {
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
        }
        if (label == 'Confirm Password') {
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
        }
        return null;
      },
      onChanged: (_) {
        setState(() {
          _fieldsTouched[label] = true;
        });
      },
    );
  }

  Widget _buildDropdown(String label, String? value, Map<String, String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (newValue) {
        onChanged(newValue);
        setState(() {
          _fieldsTouched[label] = true;
        });
      },
      validator: (value) {
        if (!_fieldsTouched[label]!) {
          return null;
        }
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownWithInfoIcon(String label, String? value, Map<String, String> items, void Function(String?) onChanged, void Function() onInfoPressed) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(label, value, items, onChanged),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onInfoPressed,
        ),
      ],
    );
  }
}
