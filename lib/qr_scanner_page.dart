import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import './services/auth_service.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final TextEditingController _manualIdController = TextEditingController();
  final MobileScannerController cameraController = MobileScannerController();
  final AuthService authService = AuthService(); // Initialize AuthService
  bool _messageDisplayed = false; // Flag to track message display

  // Check Camera Permission
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Start QR Scanner with camera permission check
  void _startQRScanner() async {
    if (await _checkCameraPermission()) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Scan QR Code'),
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(
                      cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        cameraController.toggleTorch();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        cameraController.switchCamera();
                      });
                    },
                  ),
                ],
              ),
              body: MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String code = barcodes.first.rawValue ?? '';
                    if (code.isNotEmpty) {
                      _onQRScan(code); // Process scanned QR code
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ).then((value) {
        if (value != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned: $value'),
              backgroundColor: Colors.green, // Engaging green color for success
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission denied'),
          backgroundColor: Colors.red, // Red color for error message
        ),
      );
    }
  }

  void _onQRScan(String scannedData) {
    // Validate QR code format: usernamexxeventId (case-insensitive)
    final regex = RegExp(r'^(.+?)xx(\d+)$', caseSensitive: false);
    final match = regex.firstMatch(scannedData);

    if (match != null) {
      final username = match.group(1)!.toUpperCase(); // Ensure username is uppercase
      final eventId = int.parse(match.group(2)!);
      _registerForEvent(username, eventId); // Call AuthService to register
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR Code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _registerForEvent(String username, int eventId) async {
    if (_messageDisplayed) return; // Prevent duplicate messages

    _messageDisplayed = true; // Set flag to true to indicate a message is being displayed
    ScaffoldMessenger.of(context).clearSnackBars();

    final result = await authService.registerForEvent(username, eventId, true);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $username Registered Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Failed: ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Reset the flag after a short delay to allow new messages
    Future.delayed(const Duration(seconds: 3), () {
      _messageDisplayed = false;
    });
  }

  // Submit Manually Entered ID
  void _submitManualID() {
    String enteredId = _manualIdController.text.trim();
    if (enteredId.isNotEmpty) {
      Navigator.pop(context, enteredId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid ID!'),
          backgroundColor: Colors.orange, // Orange color for warning message
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.qr_code_2, size: 150, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Point your camera at a QR code to scan.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startQRScanner,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                backgroundColor: Colors.blue, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Enter ID Manually',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _manualIdController,
              decoration: InputDecoration(
                hintText: 'Enter your ID...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit, color: Colors.blue),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _submitManualID,
              icon: const Icon(Icons.check),
              label: const Text('Submit ID'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                backgroundColor: Colors.green, // Button color for submission
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
