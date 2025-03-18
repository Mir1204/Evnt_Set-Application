import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
   final String apiUrl = "https://evntset-backend.onrender.com/api/auth";
  // final String apiUrl = "http://192.168.51.78:5000/api/auth";
   //final String apiUrl = "http://localhost:5000/api/auth";

  HttpClient createHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return httpClient;
  }

  Future<http.Client> getClient() async {
    return IOClient(createHttpClient());
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final client = await getClient();
      final response = await client.post(
        Uri.parse("$apiUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("token")) {
          await _saveToken(data["token"]);
          return {"success": true, "token": data["token"]};
        }
        return {"success": false, "error": "Token missing in response"};
      }
      return {"success": false, "error": "${response.statusCode}: ${response.body}"};
    } catch (e) {
      return {"success": false, "error": "Login failed: ${e.toString()}"};
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final client = await getClient();
      final response = await client.post(
        Uri.parse("$apiUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      }
      return {"success": false, "error": "${response.statusCode}: ${response.body}"};
    } catch (e) {
      return {"success": false, "error": "Signup failed: ${e.toString()}"};
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}
