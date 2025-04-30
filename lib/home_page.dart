import 'package:flutter/material.dart';
import './services/auth_service.dart';
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
  final AuthService _authService = AuthService();

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
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
    ),
  );

  void _showDepartmentFilter() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Wrap(
            children: departments.map((dept) {
              return ListTile(
                title: Text(dept, style: TextStyle(color: Colors.blueAccent)),
                onTap: () {
                  _onDepartmentSelected(dept);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text('Event A is starting soon!', style: TextStyle(color: Colors.blueAccent)),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text('New event added: Tech Talk', style: TextStyle(color: Colors.blueAccent)),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text('Your registration for Workshop B is confirmed.', style: TextStyle(color: Colors.blueAccent)),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text('Reminder: Seminar on AI tomorrow.', style: TextStyle(color: Colors.blueAccent)),
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text('Concert tickets are now available.', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

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
            events: _filteredEvents().cast<Map<String, dynamic>>(),
            eventTypes: eventTypes,
            selectedEventType: selectedEventType,
            onEventTypeSelected: _onEventTypeSelected,
          );
          break;

        case 2:
          bodyContent = _isAuthenticated
              ? RegisteredEventsSection(allEvents: allEvents.cast<Map<String, dynamic>>())
              : _buildUnauthorizedMessage();
          break;

        case 3:
          bodyContent = _isAuthenticated ? ProfileScreen() : _buildUnauthorizedMessage();
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        if (isSearching) {
          setState(() {
            isSearching = false;
            searchQuery = "";
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[300], // Light blue theme
          title: !isSearching
              ?  Image.asset('assets/Logo.PNG', height: 40)
              : TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search events...',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) searchQuery = "";
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onPressed: _showDepartmentFilter,
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: _showNotifications,
            ),
          ],
        ),
        body: bodyContent,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.lightBlue[100], // Light blue theme
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "For You"),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "All Events"),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Registered"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
