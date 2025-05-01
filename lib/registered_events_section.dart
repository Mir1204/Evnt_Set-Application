import 'package:flutter/material.dart';
import 'event_box.dart';
import 'eventdetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_code_page.dart';

class RegisteredEventsSection extends StatefulWidget {
  final List<Map<String, dynamic>> allEvents;

  const RegisteredEventsSection({required this.allEvents, Key? key}) : super(key: key);

  @override
  _RegisteredEventsSectionState createState() => _RegisteredEventsSectionState();
}

class _RegisteredEventsSectionState extends State<RegisteredEventsSection> {
  List<String> registeredEventNames = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  Future<void> _loadRegisteredEvents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      registeredEventNames = prefs.getStringList('registeredEvents') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final registeredEvents = widget.allEvents
        .where((event) => registeredEventNames.contains(event["eventName"]))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registered Events"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: registeredEvents.isEmpty
          ? const Center(child: Text("No registered events found."))
          : ListView.builder(
              itemCount: registeredEvents.length,
              itemBuilder: (context, index) {
                final event = registeredEvents[index];
                return EventBox(
                  posterUrl: event["posterUrl"] ?? '',
                  title: event["eventName"] ?? '',
                  dateTime: "${event["date"]} - ${event["time"]}",
                  isRegistered: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(eventData: event),
                      ),
                    );
                  },
                  showQRButton: true,
                  onShowQR: () {
                    // Navigate to QR Code Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodePage(eventId: event["eventId"]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
