import 'package:flutter/material.dart';
import 'event_section.dart';
import 'event_box.dart';
import 'widgets/sliding_event_filter.dart';
import 'eventdetail.dart';

class AllEventsPage extends StatefulWidget {
  final List<Map<String, String>> events;
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
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlidingEventFilter(
          eventTypes: widget.eventTypes,
          selectedEventType: widget.selectedEventType,
          onEventTypeSelected: widget.onEventTypeSelected,
        ),
        Expanded(
          child: EventSection(
            title: "All Events",
            events: widget.events.map((event) => EventBox(
              posterUrl: event["posterUrl"]!,
              title: event["title"]!,
              dateTime: "Jan 25, 2025 - 6:00 PM",
              isRegistered: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(
                      isStudentCoordinator: false,
                      isRegistered: false,
                      isEventCompleted: false,
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
