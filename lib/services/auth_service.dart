import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl = "https://localhost:7171/api/auth"; // Replace with your API URL

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["token"]; // Return JWT token
      } else {
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      return response.statusCode == 201; // Return true if user is successfully registered
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }
}