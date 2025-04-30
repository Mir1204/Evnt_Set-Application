import 'package:evntset/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodePage extends StatefulWidget {
  final int eventId;

  const QRCodePage({required this.eventId, Key? key}) : super(key: key);

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();
      setState(() {
        username = userData?['username'] ?? 'UnknownUser';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        username = 'UnknownUser';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Your Event QR Code")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    String qrData = '$username${"XX"}${widget.eventId.toString()}'; // Combine username and eventId

    return Scaffold(
      appBar: AppBar(title: const Text("Your Event QR Code")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scan this QR code at the event entry",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            QrImageView(
              data: qrData, // Generate QR with updated format
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 30),
            Text("Data: $qrData", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
