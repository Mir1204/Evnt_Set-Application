import 'package:flutter/material.dart';
import 'for_you_page.dart';
import 'all_events_page.dart';
import 'profile_section.dart';
import 'registered_events_section.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedEventType = "All";
  bool _isAuthenticated = false;
  String selectedDepartment = "All";

  final List<String> eventTypes = [
    "All",
    "Culture",
    "Sports",
    "Tech",
    "Workshop",
    "Seminar",
    "Conference",
    "Concert",
    "Hackathon",
    "Entertainment"
  ];

  final List<String> departments = [
    "All",
    "DEPSTAR CSE",
    "CSPIT CE",
    "CMPICA",
    "RPCP"
  ];

  final List<Map<String, String>> allEvents = [
    {
      "posterUrl": "assets/Event01.jpeg",
      "title": "Cultural Fest",
      "eventType": "Culture",
      "department": "DEPSTAR CSE"
    },
    {
      "posterUrl": "assets/Event2.jpeg",
      "title": "Tech Talk",
      "eventType": "Tech",
      "department": "CSPIT CE"
    },
    {
      "posterUrl": "assets/Event3.jpeg",
      "title": "Sports Meet",
      "eventType": "Sports",
      "department": "CMPICA"
    },
    {
      "posterUrl": "assets/Event4.jpeg",
      "title": "Seminar on AI/ML",
      "eventType": "Tech",
      "department": "DEPSTAR CSE"
    },
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  void _onEventTypeSelected(String eventType) =>
      setState(() => selectedEventType = eventType);
  void _onDepartmentSelected(String department) =>
      setState(() => selectedDepartment = department);

  List<Map<String, String>> _filteredEvents() {
    return allEvents.where((event) {
      bool matchesDepartment =
          selectedDepartment == "All" || event["department"] == selectedDepartment;
      bool matchesEventType =
          selectedEventType == "All" || event["eventType"] == selectedEventType;
      return matchesDepartment && matchesEventType;
    }).toList();
  }

  // New: A bottom sheet with a horizontal list of department chips
  void _showDepartmentFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Department",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: departments.map((dept) {
                    bool isSelected = selectedDepartment == dept;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(dept),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          _onDepartmentSelected(dept);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnauthorizedMessage() => Center(
    child: Text(
      "Please login/signup to view this section.",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = Center(child: Text("Page not found"));

    if (_selectedIndex == 3) {
      bodyContent = ProfileScreen();
    } else if (_selectedIndex == 2) {
      bodyContent =
      _isAuthenticated ? RegisteredEventsSection() : _buildUnauthorizedMessage();
    } else if (_selectedIndex == 0) {
      bodyContent = _isAuthenticated
          ? ForYouPage(
        events: _filteredEvents(),
        eventTypes: eventTypes,
        selectedEventType: selectedEventType,
        onEventTypeSelected: (val) {
          setState(() {
            selectedEventType = val;
          });
        },
      )
          : _buildUnauthorizedMessage();
    } else if (_selectedIndex == 1) {
      bodyContent = AllEventsPage(
        events: _filteredEvents(),
        eventTypes: eventTypes,
        selectedEventType: selectedEventType,
        onEventTypeSelected: (val) {
          setState(() {
            selectedEventType = val;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/Logo.PNG', height: 40),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          // Use an icon button to open the department filter bottom sheet
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showDepartmentFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Notifications"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text("Cultural Fest is starting soon!")),
                    ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text("New event: Tech Talk added.")),
                    ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text("Hackathon registration closes tomorrow.")),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"))
                ],
              ),
            ),
          ),
          if (!_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ).then((loggedIn) {
                  if (loggedIn == true)
                    setState(() => _isAuthenticated = true);
                });
              },
            ),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "For You"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "All Events"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Registered Events"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
