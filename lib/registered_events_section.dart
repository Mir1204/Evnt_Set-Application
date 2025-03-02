import 'package:flutter/material.dart';
import 'event_box.dart';
import 'eventdetail.dart';

class RegisteredEventsSection extends StatelessWidget {
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
        EventBox(
          posterUrl: "assets/event1.jpg",
          title: "Tech Talk",
          dateTime: "Jan 25, 2025 - 6:00 PM",
          isRegistered: true,
          onTap: () {
            // Navigate to EventDetailPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailPage(
                  isStudentCoordinator: false,
                  isRegistered: true,
                  isEventCompleted: false,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
