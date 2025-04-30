import 'package:flutter/material.dart';
import 'event_section.dart';
import 'event_box.dart';
import 'widgets/sliding_event_filter.dart';
import 'eventdetail.dart';
import './services/auth_service.dart';

class AllEventsPage extends StatefulWidget {
  final List<String> eventTypes;
  final String selectedEventType;
  final Function(String) onEventTypeSelected;

  const AllEventsPage({
    required this.eventTypes,
    required this.selectedEventType,
    required this.onEventTypeSelected,
    Key? key,
  }) : super(key: key);

  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<dynamic> events = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final loadedEvents = await _authService.getSavedEvents();
    if (loadedEvents != null) {
      setState(() {
        events = loadedEvents;
      });
    }
  }

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
          child: events.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : EventSection(
                  title: "All Events",
                  events: events.map((event) => EventBox(
                    posterUrl: event["posterUrl"] ?? '',
                    title: event["eventName"] ?? '',
                    dateTime: "${event["date"]} - ${event["time"]}",
                    isRegistered: false, // You can add registration logic later
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
