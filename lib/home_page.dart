import 'package:flutter/material.dart';
import './services/auth_service.dart'; // Ensure correct path
import 'for_you_page.dart';
import 'all_events_page.dart';
import 'profile_section.dart';
import 'registered_events_section.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedEventType = "All";
  String selectedDepartment = "All";
  String searchQuery = "";
  bool isSearching = false;
  bool _isAuthenticated = true; // Set this properly based on your login system
  bool _isLoading = true;

  List<dynamic> allEvents = [];
  final AuthService _authService = AuthService(); // Your auth service instance

  final List<String> eventTypes = [
    "All", "Culture", "Sports", "Tech", "Workshop", "Seminar",
    "Conference", "Concert", "Hackathon", "Entertainment"
  ];

  final List<String> departments = [
    "All", "DEPSTAR CSE", "CSPIT CE", "CMPICA", "RPCP"
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final savedEvents = await _authService.getSavedEvents();
      if (savedEvents != null) {
        setState(() {
          allEvents = savedEvents;
        });
      }
    } catch (e) {
      print("Error loading events: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  void _onEventTypeSelected(String type) => setState(() => selectedEventType = type);
  void _onDepartmentSelected(String dept) => setState(() => selectedDepartment = dept);

  List<dynamic> _filteredEvents() {
    return allEvents.where((event) {
      final type = event['type']?.toString() ?? '';
      final dept = event['iDepartment']?.toString() ?? '';
      final title = event['eventName']?.toString() ?? '';

      final matchesType = selectedEventType == "All" || selectedEventType == type;
      final matchesDept = selectedDepartment == "All" || selectedDepartment == dept;
      final matchesSearch = searchQuery.isEmpty || title.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesType && matchesDept && matchesSearch;
    }).toList();
  }

  Widget _buildUnauthorizedMessage() => Center(
        child: Text(
          "Please login/signup to view this section.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = Center(child: Text("Page not found"));

    if (_isLoading) {
      bodyContent = Center(child: CircularProgressIndicator());
    } else {
      switch (_selectedIndex) {
        case 0:
          bodyContent = _isAuthenticated
              ? ForYouPage(
                  events: _filteredEvents().cast<Map<String, dynamic>>(),
                  eventTypes: eventTypes,
                  selectedEventType: selectedEventType,
                  onEventTypeSelected: _onEventTypeSelected,
                )
              : _buildUnauthorizedMessage();
          break;

        case 1:
          bodyContent = AllEventsPage(
            eventTypes: eventTypes,
            selectedEventType: selectedEventType,
            onEventTypeSelected: _onEventTypeSelected,
          );
          break;

        case 2:
          bodyContent = _isAuthenticated ? RegisteredEventsSection() : _buildUnauthorizedMessage();
          break;

        case 3:
          bodyContent = _isAuthenticated ? ProfileScreen() : _buildUnauthorizedMessage();
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("College Events")),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "For You"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "All Events"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Registered"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
