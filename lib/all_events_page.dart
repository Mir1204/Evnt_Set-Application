import 'package:flutter/material.dart';
import 'event_section.dart';
import 'event_box.dart';
import 'widgets/sliding_event_filter.dart';
import 'eventdetail.dart';

class AllEventsPage extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final List<String> eventTypes;
  final String selectedEventType;
  final Function(String) onEventTypeSelected;

  const AllEventsPage({
    required this.events,
    required this.eventTypes,
    required this.selectedEventType,
    required this.onEventTypeSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlidingEventFilter(
          eventTypes: eventTypes,
          selectedEventType: selectedEventType,
          onEventTypeSelected: onEventTypeSelected,
        ),
        Expanded(
          child: events.isEmpty
              ? const Center(child: Text("No events found."))
              : EventSection(
            title: "All Events",
            events: events.map((event) => EventBox(
              posterUrl: event["posterUrl"] ?? '',
              title: event["eventName"] ?? '',
              dateTime: "${event["date"]} - ${event["time"]}",
              isRegistered: false, // Optional registration logic
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      eventData: event,
                    ),
                  ),
                );
              },
            )).toList(),
          ),
        ),
      ],
    );
  }
}
