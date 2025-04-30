import 'package:evntset/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService();
    final userData = await authService.getUserData();

    if (userData == null) {
      setState(() {
        isRegistered = false;
      });
      return;
    }

    final currentUsername = userData['username'];
    final storedUsername = prefs.getString('lastLoggedInUser');

    // Reset registered events if a new user logs in
    if (storedUsername != currentUsername) {
      await prefs.setString('lastLoggedInUser', currentUsername);
    }

    // Retrieve user-specific registered events
    final userEventsMap = prefs.getString('userEventsMap') ?? '{}';
    final Map<String, List<String>> userEvents = Map<String, List<String>>.from(
      (userEventsMap.isNotEmpty ? jsonDecode(userEventsMap) : {}),
    );

    final registeredEvents = userEvents[currentUsername] ?? [];
    setState(() {
      isRegistered = registeredEvents.contains(widget.eventData["eventName"]);
    });
  }

  Future<void> _registerForEvent() async {
    final authService = AuthService();
    final userData = await authService.getUserData();

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user data.')),
      );
      return;
    }

    final username = userData['username'];
    final eventId = widget.eventData["eventId"] as int;

    final response = await authService.registerForEvent(username, eventId, false);

    if (response["success"] == true) {
      setState(() {
        isRegistered = true;
      });

      // Save the event as registered for the current user
      final prefs = await SharedPreferences.getInstance();
      final userEventsMap = prefs.getString('userEventsMap') ?? '{}';
      final Map<String, List<String>> userEvents = Map<String, List<String>>.from(
        (userEventsMap.isNotEmpty ? jsonDecode(userEventsMap) : {}),
      );

      // Ensure only two users can register for the same event
      final registeredUsers = userEvents.entries
          .where((entry) => entry.value.contains(widget.eventData["eventName"]))
          .map((entry) => entry.key)
          .toList();

      if (registeredUsers.length >= 2 && !registeredUsers.contains(username)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only two users can register for this event from this device.')),
        );
        return;
      }

      userEvents[username] = (userEvents[username] ?? [])..add(widget.eventData["eventName"]);
      await prefs.setString('userEventsMap', jsonEncode(userEvents));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are successfully registered!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response["error"]}')),
      );
    }
  }

  Future<void> _navigateToQRCodePage(BuildContext context, int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 'UnknownUser';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodePage(eventId: eventId),
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
            backgroundColor: Colors.blueAccent,
            title: Text(
              widget.eventData["eventName"] ?? "Event Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                      // Event Details Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Name
                            Text(
                              widget.eventData["eventName"] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Event Poster (Full width, with height adjusted for better fit)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.eventData["posterUrl"] ?? '',
                                width: double.infinity, // Full width
                                height: MediaQuery.of(context).size.height * 0.35, // Adjusted height
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Event Description
                            Text(
                              "Description:\n${widget.eventData["description"] ?? 'No description available'}",
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            // Event Details: Date, Time, Venue
                            _buildIconText(Icons.calendar_today, 'Date', widget.eventData["date"] ?? "N/A"),
                            _buildIconText(Icons.access_time, 'Time', widget.eventData["time"] ?? "N/A"),
                            _buildIconText(Icons.location_on, 'Venue', widget.eventData["venue"] ?? "N/A"),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            // Register Button and QR Code Button
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                                    child: ElevatedButton(
                                      onPressed: isRegistered ? null : _registerForEvent,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isRegistered ? Colors.grey : Colors.blueAccent,
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
                            // Feedback Button
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
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$title: $value', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
