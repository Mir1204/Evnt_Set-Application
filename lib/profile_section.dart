import 'dart:io';
import 'editprofile.dart'; // Ensure this file exists and exports EditProfileScreen
import 'package:evntset/services/auth_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Adjust import path
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
  _loadUserData();
  }

 
Future<http.Client> createHttpClient() async {
  HttpClient client = HttpClient();
  
  // ✅ Allow self-signed certificates
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  
  return IOClient(client);
}

 Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString("user_data");

      if (userData != null) {
        final data = jsonDecode(userData);
        setState(() {
          name = data["name"] ?? "Unknown";
          id = data["id"] ?? "N/A";
          gender = data["gender"] ?? "N/A";
          mobile = data["mobile"] ?? "N/A";
          department = data["department"] ?? "N/A";
          dob = data["birthdate"] ?? "N/A";
          email = data["email"] ?? "N/A";
          studentType = data["residence"] ?? "N/A";
          // profileImagePath = data["profileImage"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No user data found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user data: ${e.toString()}";
        isLoading = false;
      });
    }
  }
  late AnimationController _animationController;
  late Animation<double> _cardAnimation;



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Profile")),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 20),
                    _buildProfilePicture(),
                    SizedBox(height: 20),
                    _buildProfileCard(),
                  ],
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
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _buildDecorativeCircle(100, 0.2),
          ),
          Positioned(
            top: 50,
            left: -30,
            child: _buildDecorativeCircle(80, 0.15),
          ),
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
Widget _buildDecorativeCircle(double size, double opacity) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );
}

/// Circular profile picture with a white border and subtle shadow.
Widget _buildProfilePicture() {
  return Center(
    child: CircleAvatar(
      radius: 75,
      backgroundColor: Colors.white,
      backgroundImage: profileImagePath != null
          ? FileImage(File(profileImagePath!))
          : AssetImage("assets/logo.jpg") as ImageProvider,
    ),
  );
}


  /// Circular profile picture with a white border and subtle shadow.
  // Widget _buildProfilePicture() {
  //   return Center(
  //     child: Container(
  //       width: 150,
  //       height: 150,
  //       decoration: BoxDecoration(
  //       //   shape: BoxShape.circle,
  //       //   border: Border.all(color: Colors.white, width: 4),
  //       //   boxShadow: const [
  //       //     BoxShadow(
  //       //       color: Colors.black26,
  //       //       blurRadius: 10,
  //       //       offset: Offset(0, 5),
  //       //     ),
  //       //   ],
  //       // ),
  //       // child: CircleAvatar(
  //       //   backgroundImage: profileImagePath != null
  //       //       ? FileImage(File(profileImagePath!))
  //       //       : const AssetImage("assets/logo.jpg") as ImageProvider,
  //       ),
  //     ),
  //   );
  // }

  /// Card containing all profile details.
  Widget _buildProfileCard() {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  if (errorMessage != null) {
    return Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)));
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


  /// A profile detail row with an icon, label, and value.
 Widget _buildProfileItem(IconData icon, String title, String value) {
  return Row(
    children: [
      Icon(icon, color: Colors.blue),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          "$title: $value",
          style: TextStyle(fontSize: 18),
        ),
      ),
    ],
  );
}

  /// A subtle divider between profile items.
Widget _buildDivider() {
  return Divider(color: Colors.grey.shade300, thickness: 1);
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