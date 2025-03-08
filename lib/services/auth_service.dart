import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class AuthService {
  final String apiUrl = "https://192.168.26.26:7172/api/auth"; // Use HTTPS

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

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey("token")) {
        return {"success": true, "token": data["token"]};
      } else {
        return {"success": false, "error": "Token missing in response"};
      }
    } else {
      return {"success": false, "error": jsonDecode(response.body)['message'] ?? "Invalid credentials"};
    }
  } catch (e) {
    print("Login Exception: $e");
    return {"success": false, "error": "Connection failed. Check your SSL certificate."};
  }
}


 Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
  try {
    final client = await getClient(); // Use the trusted client
    final response = await client.post(
      Uri.parse("$apiUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    print("Signup Response Status Code: ${response.statusCode}");
    print("Signup Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "error": jsonDecode(response.body)['message'] ?? "Signup failed"};
    }
  } catch (e) {
    print("Signup Exception: $e");
    return {"success": false, "error": "Signup Error: Check SSL certificate."};
  }
}


  Future<Map<String, dynamic>> _handlePostRequest(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 307) {
        // Handle redirect
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          print("Redirecting to: $newUrl");
          return await _handlePostRequest(newUrl, body);
        } else {
          print("Error: 307 received but no location header found.");
          return {"success": false, "error": "Redirect URL missing in server response."};
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return {"success": true, "data": data};
        } else {
          print("Error: Empty response from server");
          return {"success": false, "error": "Empty response from server"};
        }
      } else {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? "Request failed";
          print("Error: $errorMessage");
          return {"success": false, "error": errorMessage};
        } else {
          print("Error: Unexpected response from server");
          return {"success": false, "error": "Unexpected response from server"};
        }
      }
    } catch (e) {
      print("Request Exception: $e");
      return {"success": false, "error": "Request failed: $e"};
    }
  }
}
