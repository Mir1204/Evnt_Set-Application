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
      initialDate: _birthdate ?? DateTime.now(),
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
    final userData = {
      "name": _nameController.text,
      "Username": _studentIdController.text,
      "department": _selectedDepartment,
      "year": _yearController.text,
      "gender": _gender,
      "birthdate": _birthdateController.text,
      "residence": _residence,
      "mobile": _mobileController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    bool success = await _authService.signup(userData);
    if (success) {
      // Redirect to home page after successful signup
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup failed! Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              items: _departments.map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (value) => setState(() => _selectedDepartment = value!),
              decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Current Year', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Gender: "),
                Radio<String>(value: 'Male', groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                const Text("Male"),
                Radio<String>(value: 'Female', groupValue: _gender, onChanged: (value) => setState(() => _gender = value!)),
                const Text("Female"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Residence: "),
                Radio<String>(value: 'Dayscholar', groupValue: _residence, onChanged: (value) => setState(() =>_residence = value!)),
                const Text("Dayscholar"),
                Radio<String>(value: 'Hosteler', groupValue: _residence, onChanged: (value) => setState(() => _residence = value!)),
                const Text("Hosteler"),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthdateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Birthdate', border: OutlineInputBorder()),
              onTap: () => _selectBirthdate(context),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}