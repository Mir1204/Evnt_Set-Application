import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = "https://evntset-backend.onrender.com/api";
  // final String apiUrl = "http://100.116.131.0:5000/api"; // Update based on your environment
  final String apiKey = "Jay9101620"; // Replace with actual key

  HttpClient createHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return httpClient;
  }

  Future<http.Client> getClient() async {
    return IOClient(createHttpClient());
  }

  Future<Map<String, String>> _getHeaders() async {
    return {
      "Content-Type": "application/json",
      "x-api-key": "Jay9101620", // ✅ Add API Key
    };
  }

  authtocken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    return token;
  }

 Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final client = await getClient();
    final headers = await _getHeaders();

    final response = await client.post(
      Uri.parse("$apiUrl/auth/login"),
      headers: headers,
      body: jsonEncode({"username": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey("token")) {
        await _saveUserData(data);

        // ✅ Fetch and store events after login
        await fetchEvents();

        return {"success": true, "token": data["token"]};
      }
      return {"success": false, "error": "Token missing in response"};
    }
    return {
      "success": false,
      "error": "${response.statusCode}: ${response.body}"
    };
  } catch (e) {
    return {"success": false, "error": "Login failed: ${e.toString()}"};
  }
}

  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final client = await getClient();
      final headers = await _getHeaders(); // ✅ Secure headers with API Key

      final response = await client.post(
        Uri.parse("$apiUrl/auth/register"),
        headers: headers,
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      }
      return {
        "success": false,
        "error": "${response.statusCode}: ${response.body}"
      };
    } catch (e) {
      return {"success": false, "error": "Signup failed: ${e.toString()}"};
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", data["token"]);
    await prefs.setString("user", jsonEncode(data["user"]));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("user");
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  Future<String?> getUserDepartment() async {
    final userData = await getUserData();
    return userData?['department'];
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user");
  }

    Future<List<dynamic>> fetchEvents() async {
    try {
      final client = await getClient();
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse("$apiUrl/events"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = jsonDecode(response.body);

        // Save events locally
        await _saveEventsData(events);

        return events; // Return the events list
      } else {
        throw Exception(
            "Failed to load events: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to fetch events: ${e.toString()}");
    }
  }

  Future<void> _saveEventsData(List<dynamic> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("events_data", jsonEncode(events));
  }

  Future<List<dynamic>?> getSavedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsData = prefs.getString("events_data");
    if (eventsData != null) {
      return jsonDecode(eventsData);
    }
    return null;
  }

  Map<String, dynamic>? tempEventRegistrationData;

  Future<Map<String, dynamic>> registerForEvent(String username, int eventId, bool attendance) async {
    try {
      final client = await getClient();
      final headers = await _getHeaders();

      final response = await client.post(
        Uri.parse("https://evntset-backend.onrender.com/eventreg"),
        headers: headers,
        body: jsonEncode({
          "Username": username,
          "eventId": eventId.toString(),
          "Attendance": attendance,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        tempEventRegistrationData = data; // Save in temporary memory
        return {"success": true, "data": data};
      }
      return {
        "success": false,
        "error": "${response.statusCode}: ${response.body}"
      };
    } catch (e) {
      return {"success": false, "error": "Event registration failed: ${e.toString()}"};
    }
  }

}
