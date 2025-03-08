import 'package:flutter/material.dart';
import './services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  static const String routeName = '/signup';

  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedDepartment = 'DEPSTAR';
  final List<String> _departments = ['DEPSTAR', 'CSPIT', 'RPCP', 'CMPICA', 'IIIM'];

  String _gender = 'Male';
  String _residence = 'DayScholar';
  DateTime? _birthdate;

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdate = picked;
        _birthdateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      "name": _nameController.text.trim(),
      "username": _studentIdController.text.trim(),
      "department": _selectedDepartment,
      "year": _yearController.text.trim(),
      "gender": _gender,
      "birthdate": _birthdateController.text.trim(),
      "residence": _residence,
      "mobile": _mobileController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    final response = await _authService.signup(userData);
    if (response['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${response['error']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _nameController, label: 'Name', validator: _validateRequired),
              _buildTextField(controller: _studentIdController, label: 'Student ID', validator: _validateRequired),
              _buildDropdown(),
              _buildTextField(controller: _yearController, label: 'Current Year', inputType: TextInputType.number, validator: _validateRequired),
              _buildGenderSelection(),
              _buildResidenceSelection(),
              _buildTextField(controller: _birthdateController, label: 'Birthdate', readOnly: true, onTap: () => _selectBirthdate(context), validator: _validateRequired),
              _buildTextField(controller: _mobileController, label: 'Mobile Number', inputType: TextInputType.phone, validator: _validateMobile),
              _buildTextField(controller: _emailController, label: 'Email', inputType: TextInputType.emailAddress, validator: _validateEmail),
              _buildTextField(controller: _passwordController, label: 'Password', obscureText: true, validator: _validatePassword),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _registerUser, child: const Text('Sign Up')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: inputType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        items: _departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept))).toList(),
        onChanged: (value) => setState(() => _selectedDepartment = value!),
        decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Text("Gender: "),
          _buildRadio('Male', _gender, (value) => setState(() => _gender = value!)),
          _buildRadio('Female', _gender, (value) => setState(() => _gender = value!)),
        ],
      ),
    );
  }

  Widget _buildResidenceSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Text("Residence: "),
          _buildRadio('DayScholar', _residence, (value) => setState(() => _residence = value!)),
          _buildRadio('Hosteler', _residence, (value) => setState(() => _residence = value!)),
        ],
      ),
    );
  }

  Widget _buildRadio(String value, String groupValue, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged),
        Text(value),
      ],
    );
  }

  // Validators
  String? _validateRequired(String? value) => value == null || value.isEmpty ? 'This field is required' : null;
  String? _validateEmail(String? value) => value != null && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value) ? 'Enter a valid email' : null;
  String? _validateMobile(String? value) => value != null && value.length != 10 ? 'Enter a valid mobile number' : null;
  String? _validatePassword(String? value) => value != null && value.length < 6 ? 'Password must be at least 6 characters' : null;
}
