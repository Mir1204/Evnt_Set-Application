import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For Date Formatting

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _currentYearController = TextEditingController();

  bool _isPasswordVisible = false;
  String _gender = "Male"; // Default selection
  String _residence = "DayScholar"; // Default selection
  DateTime? _selectedDate; // For DOB selection

  // Helper method to build a Radio Button Group
  Widget _buildRadioGroup(String title, List<String> options, String groupValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        Row(
          children: options.map((option) {
            return Expanded(
              child: Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: groupValue,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) => setState(() => onChanged(value!)),
                  ),
                  Text(option, style: const TextStyle(color: Colors.black)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Show a Snackbar for messages
  void _showMessage(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Date Picker for DOB
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1), // Default to 2005
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Validate and Sign Up
  void _signUp() {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String studentId = _studentIdController.text.trim();
    String password = _passwordController.text.trim();
    String mobile = _mobileController.text.trim();
    String currentYear = _currentYearController.text.trim();

    if (name.isEmpty || email.isEmpty || studentId.isEmpty || password.isEmpty || mobile.isEmpty || currentYear.isEmpty || _selectedDate == null) {
      _showMessage("Please fill in all fields.");
      return;
    }

    if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      _showMessage("Enter a valid 10-digit mobile number.");
      return;
    }

    _showMessage("Signup successful!", color: Colors.green);

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.lightBlue], // Blue Theme 🌊
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 📦 Signup Card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 15),

                      // 👤 Name Field
                      _buildTextField(_nameController, "Full Name", Icons.person),

                      // ✉️ Email Field
                      _buildTextField(_emailController, "Email", Icons.email),

                      // 🆔 Student ID Field
                      _buildTextField(_studentIdController, "Student ID", Icons.badge),

                      // 📅 DOB Picker
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                              labelStyle: const TextStyle(color: Colors.blueAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.lightBlueAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            controller: TextEditingController(
                              text: _selectedDate == null ? "" : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 📱 Mobile Number Field
                      _buildTextField(_mobileController, "Mobile Number", Icons.phone, keyboardType: TextInputType.phone),

                      // 📅 Current Year Field
                      _buildTextField(_currentYearController, "Current Year", Icons.calendar_month, keyboardType: TextInputType.number),

                      // 🎯 Gender Selection
                      _buildRadioGroup("Gender", ["Male", "Female"], _gender, (val) => _gender = val),

                      // 🏡 Residence Selection
                      _buildRadioGroup("Residence", ["DayScholar", "Hosteler"], _residence, (val) => _residence = val),

                      // 🔒 Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          labelStyle: const TextStyle(color: Colors.blueAccent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 20),

                      // 🔘 Sign Up Button
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Text Fields
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
