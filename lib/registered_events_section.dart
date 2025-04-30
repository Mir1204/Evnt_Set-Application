import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_box.dart';
import 'eventdetail.dart';

class RegisteredEventsSection extends StatefulWidget {
  @override
  _RegisteredEventsSectionState createState() => _RegisteredEventsSectionState();
}

class _RegisteredEventsSectionState extends State<RegisteredEventsSection> {
  List<String> registeredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  Future<void> _loadRegisteredEvents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      registeredEvents = prefs.getStringList('registeredEvents') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        const Text(
          "Registered Events",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...registeredEvents.map((eventName) => EventBox(
              posterUrl: "assets/event_placeholder.jpg", // Placeholder image
              title: eventName,
              dateTime: "TBD", // Placeholder date/time
              isRegistered: true,
              onTap: () {
                // Navigate to EventDetailPage with dummy data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      eventData: {
                        "eventName": eventName,
                        "posterUrl": "assets/event_placeholder.jpg",
                        "date": "TBD",
                        "time": "TBD",
                        "description": "Event details not available.",
                      },
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }
}
