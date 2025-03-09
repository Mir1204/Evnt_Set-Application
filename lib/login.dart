import 'package:flutter/material.dart';
import './services/auth_service.dart';
import 'home_page.dart';
import 'signup.dart'; // Import the SignUpPage

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
void _login() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showError("Please enter both email and password.");
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final result = await _authService.login(email, password);
    print("Login API Response: $result"); // Debugging

    if (result == null || result.isEmpty) {
      _showError("Server returned an empty response. Please try again.");
      return;
    }

    if (result["success"] == true) {
    print("Login successful, Token: ${result['token']}");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
} else {
    _showError(result["error"] ?? "Incorrect username or password.");
}

  } catch (e) {
    _showError("Login failed: ${e.toString()}");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
