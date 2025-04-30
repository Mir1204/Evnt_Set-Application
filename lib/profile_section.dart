import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:evntset/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // Profile data
  String name = "";
  String id = "";
  String gender = "";
  String mobile = "";
  String department = "";
  String dob = "";
  String email = "";
  String studentType = "";
  String? profileImagePath;

  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<double> _cardAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _fetchProfile();
    _loadProfileImage(); // Load the saved image path
  }

  Future<http.Client> createHttpClient() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(client);
  }

  Future<void> _fetchProfile() async {
    try {
      final authService = AuthService();
      final token = await authService.authtocken();
      if (token == null) {
        setState(() {
          errorMessage = "User not authenticated";
          isLoading = false;
        });
        return;
      }

      final userData = await authService.getUserData();
      if (userData != null) {
        setState(() {
          name = userData['name'];
          id = userData['username'];
          gender = userData['gender'];
          mobile = userData['mobile'];
          department = userData['department'];
          dob = userData['birthdate'];
          email = userData['email'];
          studentType = userData['residence'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load profile data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  // Load the profile image path from SharedPreferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImagePath = prefs.getString('profileImagePath');
    });
  }

  // Save the profile image path to SharedPreferences
  Future<void> _saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImagePath', imagePath);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImagePath = pickedFile.path;
      });
      _saveProfileImage(pickedFile.path); // Save the new image path
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              Container(
                height: 300,
                child: Stack(
                  children: [
                    _buildHeader(),
                    Positioned(
                      top: 150,
                      left: 0,
                      right: 0,
                      child: _buildProfilePicture(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 0.1), end: Offset.zero)
                    .animate(_cardAnimation),
                child: FadeTransition(
                  opacity: _cardAnimation,
                  child: _buildProfileCard(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 250,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "My Profile",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: profileImagePath != null
                    ? FileImage(File(profileImagePath!))
                    : const AssetImage("assets/logo.jpg") as ImageProvider,
              ),
            ),
            const Positioned(
              bottom: 10,
              right: 10,
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileItem(Icons.person_outline, "Name", name),
              _buildDivider(),
              _buildProfileItem(Icons.badge_outlined, "ID", id),
              _buildDivider(),
              _buildProfileItem(Icons.person, "Gender", gender),
              _buildDivider(),
              _buildProfileItem(Icons.phone, "Mobile", mobile),
              _buildDivider(),
              _buildProfileItem(Icons.school, "Department", department),
              _buildDivider(),
              _buildProfileItem(Icons.calendar_today, "DOB", dob),
              _buildDivider(),
              _buildProfileItem(Icons.email_outlined, "Email", email),
              _buildDivider(),
              _buildProfileItem(Icons.category, "Student Type", studentType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 20,
      color: Colors.grey[300],
      thickness: 1,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
