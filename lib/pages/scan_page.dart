import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode/QR')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  setState(() => scannedCode = barcode.rawValue);
                  // Navigate or update product based on scan (e.g., auto-fill in add screen)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scanned: $scannedCode')),
                  );
                }
              },
            ),
          ),
          if (scannedCode != null) Text('Scanned Code: $scannedCode'),
        ],
      ),
    );
  }
}