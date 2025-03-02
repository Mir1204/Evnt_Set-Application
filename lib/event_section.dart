import 'package:flutter/material.dart';

class EventSection extends StatelessWidget {
  final String title;
  final List<Widget> events;

  const EventSection({required this.title, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...events,
      ],
    );
  }
}
