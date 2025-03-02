import 'dart:io';
import 'package:flutter/material.dart';
import 'editprofile.dart'; // Ensure this file exists and exports EditProfileScreen

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
        textTheme: TextTheme(
          // Using titleLarge and bodyMedium for newer versions
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
      home: ProfileScreen(),
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
  String name = "Mir Patel";
  String id = "23DCS086";
  String gender = "Male";
  String mobile = "9106413122";
  String department = "DEPSTAR CSE";
  String dob = "30.09.2005";
  String email = "mirpatel05.mp@gmail.com";
  String studentType = "Day Scholar";
  String? profileImagePath;

  late AnimationController _animationController;
  late Animation<double> _cardAnimation;

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                // Header and profile picture container.
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
                // Animated profile details card.
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_cardAnimation),
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
      ),
    );
  }

  /// A more beautiful header with a wavy bottom edge, decorative shapes, and modern typography.
  Widget _buildHeader() {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Large decorative circle in the top-right.
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            // Smaller decorative circle in the top-left.
            Positioned(
              top: 50,
              left: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            // A rotated square for extra flair.
            Positioned(
              bottom: 30,
              right: 20,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            // Centered header title.
            Align(
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
            // Edit button in the top-right corner.
            Positioned(
              top: 40,
              right: 20,
              child: _buildEditButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Circular profile picture with a white border and subtle shadow.
  Widget _buildProfilePicture() {
    return Center(
      child: Container(
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
              : const AssetImage("assets/profile.jpg") as ImageProvider,
        ),
      ),
    );
  }

  /// Card containing all profile details.
  Widget _buildProfileCard() {
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

  /// A profile detail row with an icon, label, and value.
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

  /// A subtle divider between profile items.
  Widget _buildDivider() {
    return Divider(
      height: 20,
      color: Colors.grey[300],
      thickness: 1,
    );
  }

  /// An edit button that navigates to the EditProfileScreen.
  Widget _buildEditButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileScreen(
              userData: {
                "name": name,
                "id": id,
                "gender": gender,
                "mobile": mobile,
                "department": department,
                "dob": dob,
                "email": email,
                "studentType": studentType,
                "profileImagePath": profileImagePath,
              },
            ),
          ),
        ).then((updatedData) {
          if (updatedData != null) {
            setState(() {
              name = updatedData['name'];
              id = updatedData['id'];
              gender = updatedData['gender'];
              mobile = updatedData['mobile'];
              department = updatedData['department'];
              dob = updatedData['dob'];
              email = updatedData['email'];
              studentType = updatedData['studentType'];
              profileImagePath = updatedData['profileImagePath'];
            });
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, color: Colors.white, size: 24),
      ),
    );
  }
}

/// Custom clipper that creates a wavy bottom edge for the header.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start at top left.
    path.lineTo(0, size.height - 40);
    // First curve.
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    // Second curve.
    var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    // Line to top right and close.
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
