import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final TextEditingController _manualIdController = TextEditingController();
  final MobileScannerController cameraController = MobileScannerController();

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  void _startQRScanner() async {
    if (await _checkCameraPermission()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Scan QR Code'),
              actions: [
                IconButton(
                  icon: Icon(
                    cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
                  ),
                  onPressed: () {
                    setState(() {
                      cameraController.toggleTorch();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cameraswitch),
                  onPressed: cameraController.switchCamera,
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
                    Navigator.pop(context, code);
                  }
                }
              },
            ),
          ),
        ),
      ).then((value) {
        if (value != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanned: $value')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
    }
  }

  void _submitManualID() {
    String enteredId = _manualIdController.text.trim();
    if (enteredId.isNotEmpty) {
      Navigator.pop(context, enteredId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid ID!')),
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
      appBar: AppBar(title: const Text('Scan QR Code')),
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
                backgroundColor: Colors.blue,
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
                backgroundColor: Colors.green,
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
