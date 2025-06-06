import 'package:flutter/material.dart';

class MonthlyInvoicesScreen extends StatelessWidget {
  const MonthlyInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 20, 20),
        foregroundColor: Colors.white,
        title: const Text('Monthly Invoices'),
      ),
      body: const Center(
        child: Text(
          'Conteúdo futuro aqui...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

