import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Invoice Details'),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '• Starbucks - \$5.99\n• Netflix - \$13.99\n• Uber - \$12.40\n• iCloud - \$0.99\n• Spotify - \$16.90',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
