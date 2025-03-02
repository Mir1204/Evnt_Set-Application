import 'package:flutter/material.dart';
import 'qr_scanner_page.dart';

class EventDetailPage extends StatelessWidget {
  final bool isStudentCoordinator;
  final bool isRegistered;
  final bool isEventCompleted;

  const EventDetailPage({
    Key? key,
    required this.isStudentCoordinator,
    required this.isRegistered,
    required this.isEventCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TechX Conference 2025'),
        actions: [
          if (true)//isStudentCoordinator
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScannerPage()),
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
                        const Text(
                          'TechX Conference 2025',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/Event5.jpeg',
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Join us for an immersive experience in technology, innovation, and networking. '
                              'Learn from industry experts, participate in hands-on workshops, and connect with like-minded individuals!',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        _buildIconText(Icons.calendar_today, 'Date & Time', '10th February 2025, 10:00 AM - 5:00 PM'),
                        _buildIconText(Icons.location_on, 'Venue', '229 Seminar Hall, DEPSTAR'),
                        const SizedBox(height: 20),
                        _buildIconText(Icons.person, 'Organizer', 'Rudra Patel'),
                        _buildIconText(Icons.phone, 'Contact', '8884883483'),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Keynote Speakers',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildSpeakerTile('Dr. A.P. Sharma', 'AI Researcher, Google'),
                        _buildSpeakerTile('Neha Mehta', 'Blockchain Expert, Ethereum Foundation'),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Schedule',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildScheduleTile('10:00 AM', 'Opening Ceremony'),
                        _buildScheduleTile('11:00 AM', 'AI & Future Tech - Dr. A.P. Sharma'),
                        _buildScheduleTile('02:00 PM', 'Blockchain Innovations - Neha Mehta'),
                        _buildScheduleTile('04:00 PM', 'Panel Discussion & Networking'),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Event Rules & Guidelines',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildBulletPoint('Arrive at least 15 minutes before the session.'),
                        _buildBulletPoint('Carry a valid ID for entry.'),
                        _buildBulletPoint('Respect all participants and speakers.'),
                        _buildBulletPoint('Follow the university guidelines for COVID-19 safety.'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            String message;
                            if (!isRegistered) {
                              message = 'You are now registered!';
                            } else if (!isEventCompleted) {
                              message = 'Showing your QR Code...';
                            } else {
                              message = 'Downloading your certificate...';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                          },
                          icon: Icon(!isRegistered ? Icons.event_available : isEventCompleted ? Icons.download : Icons.qr_code),
                          label: Text(!isRegistered ? 'Register Now' : isEventCompleted ? 'Download Certificate' : 'Show QR Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          child: Text('Photo/Video ${index + 1}', style: const TextStyle(color: Colors.black54)),
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
  }

  Widget _buildIconText(IconData icon, String title, String value) {
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

  Widget _buildSpeakerTile(String name, String role) {
    return ListTile(
      leading: const Icon(Icons.person_outline, color: Colors.blue),
      title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  Widget _buildScheduleTile(String time, String session) {
    return ListTile(
      leading: const Icon(Icons.schedule, color: Colors.blue),
      title: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(session),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 6, color: Colors.blue),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: EventDetailPage(
      isStudentCoordinator: true,
      isRegistered: false,
      isEventCompleted: false,
    ),
  ));
}