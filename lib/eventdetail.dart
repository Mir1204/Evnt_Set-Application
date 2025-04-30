import 'package:evntset/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_scanner_page.dart';
import 'feedback.dart';
import 'qr_code_page.dart';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailPage({required this.eventData, Key? key}) : super(key: key);

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isRegistered = false;

  Future<void> _registerForEvent() async {
    // Simulate registration logic
    setState(() {
      isRegistered = true;
    });

    // Save the event as registered in shared preferences
    final prefs = await SharedPreferences.getInstance();
    List<String> registeredEvents = prefs.getStringList('registeredEvents') ?? [];
    registeredEvents.add(widget.eventData["eventName"]);
    await prefs.setStringList('registeredEvents', registeredEvents);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are successfully registered!')),
    );
  }

  Future<void> _navigateToQRCodePage(BuildContext context, int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'UnknownUser';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodePage( eventId: eventId),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getFilteredEvents() async {
    final authService = AuthService();
    final userDepartment = await authService.getUserDepartment();
    final savedEvents = await authService.getSavedEvents();

    if (userDepartment == null || savedEvents == null) {
      return [];
    }

    return savedEvents
        .where((event) => widget.eventData['idepartment'] == userDepartment)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final isCoordinator = userData != null &&
            (widget.eventData["coordinators"] as List<dynamic>)
                .contains(userData["username"]);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.eventData["eventName"] ?? "Event Details"),
            actions: [
              if (isCoordinator)
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QRScannerPage()),
                    );
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processed ID: $result')),
                      );
                    }
                  },
                ),
            ],
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Details', icon: Icon(Icons.info_outline)),
                    Tab(text: 'Gallery', icon: Icon(Icons.photo_library_outlined)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ${widget.eventData}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.eventData["posterUrl"] ?? '',
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "Description:\n${widget.eventData["description"]}",
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            _buildIconText(Icons.calendar_today, 'Date', widget.eventData["date"] ?? "N/A"),
                            _buildIconText(Icons.access_time, 'Time', widget.eventData["time"] ?? "N/A"),
                            _buildIconText(Icons.location_on, 'Venue', widget.eventData["venue"] ?? "N/A"),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                    child: ElevatedButton(
                                      onPressed: isRegistered ? null : _registerForEvent,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isRegistered ? Colors.grey : Colors.blue,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(isRegistered ? 'Registered' : 'Register Now'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: isRegistered && (widget.eventData["eventId"] != null)
                                          ? () => _navigateToQRCodePage(context, widget.eventData["eventId"] as int)
                                          : null,
                                      icon: const Icon(Icons.qr_code_2),
                                      label: const Text('Show QR Code'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isRegistered ? Colors.green : Colors.grey,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => FeedbackPage()),
                                        );
                                      },
                                      icon: const Icon(Icons.feedback),
                                      label: const Text('Feedback'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Gallery Tab
                      GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('Photo/Video ${index + 1}',
                                  style: const TextStyle(color: Colors.black54)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildIconText(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$title: $value', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

