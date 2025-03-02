import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _profileImage;
  late TextEditingController _nameController,
      _idController,
      _mobileController,
      _emailController,
      _dobController;
  late String _selectedGender, _selectedDepartment, _selectedStudentType;

  final _departments = [
    "DEPSTAR CSE",
    "CSPIT CE",
    "RPCP",
    "IIIM",
    "PDPIAS",
    "ARIP",
    "MTIN"
  ];
  final _genders = ["Male", "Female", "Other"];
  final _studentTypes = ["Day Scholar", "Hosteller"];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeSelections();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.userData['name']);
    _idController = TextEditingController(text: widget.userData['id']);
    _mobileController =
        TextEditingController(text: widget.userData['mobile']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _dobController = TextEditingController(text: widget.userData['dob']);
  }

  void _initializeSelections() {
    _selectedGender = widget.userData['gender'];
    _selectedDepartment = widget.userData['department'];
    _selectedStudentType = widget.userData['studentType'];
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _profileImage = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: ${e.toString()}")),
      );
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd.MM.yyyy').format(pickedDate);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'id': _idController.text,
        'mobile': _mobileController.text,
        'email': _emailController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'department': _selectedDepartment,
        'studentType': _selectedStudentType,
        // Changed key from 'profileImage' to 'profileImagePath'
        'profileImagePath': _profileImage?.path ?? widget.userData['profileImagePath'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 30),
                _buildFormFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white70,
            backgroundImage: _getProfileImage(),
            child: _profileImage == null &&
                widget.userData['profileImagePath'] == null
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Tap to change photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_profileImage != null) return FileImage(_profileImage!);
    if (widget.userData['profileImagePath'] != null) {
      return FileImage(File(widget.userData['profileImagePath']));
    }
    return null;
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputField(
                _nameController, 'Full Name', Icons.person),
            const SizedBox(height: 15),
            _buildInputField(
                _idController, 'Student ID', Icons.badge),
            const SizedBox(height: 15),
            _buildInputField(
                _mobileController, 'Mobile', Icons.phone, TextInputType.phone),
            const SizedBox(height: 15),
            _buildDropdown('Department', _departments, _selectedDepartment,
                Icons.school, (newValue) {
                  setState(() => _selectedDepartment = newValue!);
                }),
            const SizedBox(height: 15),
            _buildDropdown('Gender', _genders, _selectedGender, Icons.person,
                    (newValue) {
                  setState(() => _selectedGender = newValue!);
                }),
            const SizedBox(height: 15),
            _buildDateField(),
            const SizedBox(height: 15),
            _buildInputField(_emailController, 'Email', Icons.email,
                TextInputType.emailAddress),
            const SizedBox(height: 15),
            _buildDropdown('Student Type', _studentTypes, _selectedStudentType,
                Icons.home, (newValue) {
                  setState(() => _selectedStudentType = newValue!);
                }),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveProfile,
              child: const Text('SAVE CHANGES',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      IconData icon,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) =>
      value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      IconData icon, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      onTap: _selectDate,
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
