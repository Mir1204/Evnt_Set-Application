import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/auth_service.dart'; // Ensure this import path is correct
import 'event_section.dart';
import 'event_box.dart';
import 'widgets/sliding_event_filter.dart';
import 'eventdetail.dart';

class ForYouPage extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final List<String> eventTypes;
  final String selectedEventType;
  final Function(String) onEventTypeSelected;

  const ForYouPage({
    required this.events,
    required this.eventTypes,
    required this.selectedEventType,
    required this.onEventTypeSelected,
    Key? key,
  }) : super(key: key);

  @override
  _ForYouPageState createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  String? authToken;
  bool isLoading = true;
  List<Map<String, dynamic>> displayedEvents = [];
  String? collegeName; // College derived from token

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = AuthService();
    authToken = await authService.getToken();

    if (authToken == null) {
      print("User is not logged in!");
    } else {
      print("User is logged in");
      try {
        // Decode token to get college
        final decodedToken = _decodeToken(authToken!);
        collegeName = decodedToken['college']; // Adjust key as per your token
        _loadEvents();
      } catch (e) {
        print("Error decoding token: $e");
        // Handle error (e.g., show message)
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded);
  }

  void _loadEvents() {
    if (collegeName == null) return;

    setState(() {
      // Filter events by the user's college
      displayedEvents = widget.events.where((event) {
        return event["collegeName"] == collegeName;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (authToken == null) {
      return Center(
        child: Text(
          "Please login/signup to view this section",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return Column(
      children: [
        SlidingEventFilter(
          eventTypes: widget.eventTypes,
          selectedEventType: widget.selectedEventType,
          onEventTypeSelected: widget.onEventTypeSelected,
        ),
        Expanded(
          child: displayedEvents.isNotEmpty
              ? EventSection(
            title: "For You",
            events: displayedEvents.map((event) => EventBox(
              posterUrl: event["posterUrl"] ?? "assets/default_poster.png",
              title: event["title"] ?? "Untitled Event",
              dateTime: event["dateTime"] ?? "Date Not Available",
              isRegistered: event["isRegistered"] ?? false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      isStudentCoordinator: event["isStudentCoordinator"] ?? false,
                      isRegistered: event["isRegistered"] ?? false,
                      isEventCompleted: event["isEventCompleted"] ?? false,
                    ),
                  ),
                );
              },
            )).toList(),
          )
              : Center(
            child: Text(
              "No events available for your college.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}