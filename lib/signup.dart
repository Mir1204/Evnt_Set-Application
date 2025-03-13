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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup successful! Please log in."), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${response['error']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFF64B5F6)], // Light blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(controller: _nameController, label: 'Full Name'),
                    _buildTextField(controller: _studentIdController, label: 'Student ID'),
                    _buildDropdown(),
                    _buildTextField(controller: _yearController, label: 'Current Year', inputType: TextInputType.number),
                    _buildGenderSelection(),
                    _buildResidenceSelection(),
                    _buildTextField(controller: _birthdateController, label: 'Birthdate', readOnly: true, onTap: () => _selectBirthdate(context)),
                    _buildTextField(controller: _mobileController, label: 'Mobile Number', inputType: TextInputType.phone),
                    _buildTextField(controller: _emailController, label: 'Email', inputType: TextInputType.emailAddress),
                    _buildTextField(controller: _passwordController, label: 'Password', obscureText: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login", style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ],
                ),
              ),
            ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: inputType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueGrey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        items: _departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(color: Colors.black)))).toList(),
        onChanged: (value) => setState(() => _selectedDepartment = value!),
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: 'Department',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return _buildRadioSelection("Gender", ['Male', 'Female'], _gender, (value) => setState(() => _gender = value!));
  }

  Widget _buildResidenceSelection() {
    return _buildRadioSelection("Residence", ['DayScholar', 'Hosteler'], _residence, (value) => setState(() => _residence = value!));
  }

  Widget _buildRadioSelection(String title, List<String> options, String groupValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        Row(
          children: options.map((option) => Row(children: [Radio<String>(value: option, groupValue: groupValue, onChanged: onChanged), Text(option, style: const TextStyle(color: Colors.black))])).toList(),
        ),
      ],
    );
  }
}
