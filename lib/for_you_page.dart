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
  String? userDepartment;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    final authService = AuthService();
    final department = await authService.getUserDepartment();
    final savedEvents = await authService.getSavedEvents();

    setState(() {
      userDepartment = department;
      displayedEvents = _filterEvents(savedEvents ?? []);
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _filterEvents(List<dynamic> events) {
    if (userDepartment == null) return [];
    return events
        .where((event) => event['idepartment'] == userDepartment)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (userDepartment == null) {
      return Center(
        child: Text(
          "Unable to load events. Please try again later.",
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
                          builder: (context) => EventDetailPage(eventData: event),
                        ),
                      );
                    },
                  )).toList(),
                )
              : Center(
                  child: Text(
                    "No events available for your department.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }
}