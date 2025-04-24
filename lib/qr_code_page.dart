import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatelessWidget {
  final String data;

  // Provide default sample data if none is passed.
  const QRCodePage({this.data = "EventID12345", Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              data: data,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 30),
            Text("Data: $data", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
