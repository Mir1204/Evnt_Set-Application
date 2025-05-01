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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Department",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: departments.map((dept) {
                  final isSelected = dept == selectedDepartment;
                  return ChoiceChip(
                    label: Text(dept),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (_) {
                      _onDepartmentSelected(dept);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Notifications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                separatorBuilder: (_, __) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final notifications = [
                    "AI/ML event is starting soon!",
                    "New event added: Tech Talk",
                    "Your registration for Workshop B is confirmed.",
                    "Reminder: Seminar on Blockchain tomorrow.",
                    "Concert tickets are now available."
                  ];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.notifications_active_rounded, color: Colors.blueAccent),
                      title: Text(notifications[index]),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {}, // Add optional navigation
                    ),
                  );
                },
              ),
            ),
          ],
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
      behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard
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
              ? GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 1; // Navigate to All Events page
              });
            },
            child: Image.asset('assets/Logo.PNG', height: 40),
          )
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
            if (_selectedIndex == 1) ...[
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
            ],
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
